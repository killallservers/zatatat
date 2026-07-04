// diff.zig - Core terminal diff engine for Bun FFI
// Single-pass cell-by-cell diffing algorithm
// Compiles to native .so/.dylib/.dll for Bun's dlopen()

const std = @import("std");

const CONTINUATION_CELL: u32 = 0x0011_0000;

/// Renderer - Double-buffered terminal renderer
/// Tracks front buffer (previous frame) and diffs against back buffer (current frame)
pub const Renderer = struct {
    width: u16,
    height: u16,
    row_offset: u16,
    front_buffer: []u32,
    allocator: std.mem.Allocator,

    /// Initialize renderer with given dimensions
    /// Allocates memory via provided allocator
    pub fn init(allocator: std.mem.Allocator, width: u16, height: u16) !*Renderer {
        const self = try allocator.create(Renderer);
        const size = @as(usize, width) * @as(usize, height) * 2;
        const front_buffer = try allocator.alloc(u32, size);
        @memset(front_buffer, 0xFFFFFFFF); // u32::MAX sentinel for first frame diff

        self.* = Renderer{
            .width = width,
            .height = height,
            .row_offset = 0,
            .front_buffer = front_buffer,
            .allocator = allocator,
        };
        return self;
    }

    /// Clean up resources
    pub fn deinit(self: *Renderer) void {
        self.allocator.free(self.front_buffer);
        self.allocator.destroy(self);
    }

    /// Set row offset for inline rendering mode
    /// All cursor positioning will be shifted down by this many rows
    pub fn setRowOffset(self: *Renderer, offset: u16) void {
        self.row_offset = offset;
    }

    /// Core diff algorithm: single-pass cell comparison
    /// Returns ANSI escape sequence string needed to update terminal
    /// 
    /// Buffer format:
    ///   buffer[i*2]     = char code (u32)
    ///   buffer[i*2 + 1] = (styles << 16) | (bg << 8) | fg
    pub fn renderDiff(self: *Renderer, back_buffer: []const u32, allocator: std.mem.Allocator) ![]u8 {
        var output = std.ArrayList(u8).init(allocator);
        errdefer output.deinit();

        // Pre-allocate capacity to avoid frequent reallocations
        try output.ensureTotalCapacity(8192);

        // Prefix with reset to ensure consistent starting state
        try output.appendSlice("\x1b[0m");

        var current_x: i32 = -1;
        var current_y: i32 = -1;
        var last_fg: u8 = 255;
        var last_bg: u8 = 255;
        var last_style: u8 = 0;

        const cols = self.width;
        const cells = @as(usize, cols) * @as(usize, self.height);

        // Single pass through all cells
        var i: usize = 0;
        while (i < cells) : (i += 1) {
            const offset = i * 2;
            if (offset + 1 >= back_buffer.len) break;

            const char_code = back_buffer[offset];
            const attr_code = back_buffer[offset + 1];

            // Skip if cell hasn't changed
            if (char_code == self.front_buffer[offset] and
                attr_code == self.front_buffer[offset + 1])
            {
                continue;
            }

            // Handle continuation marker for trailing cell of wide glyph
            if (char_code == CONTINUATION_CELL) {
                self.front_buffer[offset] = char_code;
                self.front_buffer[offset + 1] = attr_code;
                current_x = @as(i32, @intCast(i % cols));
                current_y = @as(i32, @intCast(i / cols));
                continue;
            }

            const x = @as(i32, @intCast(i % cols));
            const y = @as(i32, @intCast(i / cols));

            // Only move cursor if not contiguous with previous write
            // current_x tracks the last occupied cell index
            if (current_x + 1 != x or current_y != y) {
                try writeCursorMove(&output, @as(u16, @intCast(x)), @as(u16, @intCast(y)) + self.row_offset);
            }

            // Extract color and style attributes from attr_code
            // Layout: (styles << 16) | (bg << 8) | fg
            const fg = @as(u8, @intCast(attr_code & 0xFF));
            const bg = @as(u8, @intCast((attr_code >> 8) & 0xFF));
            const styles = @as(u8, @intCast((attr_code >> 16) & 0xFF));

            // Convert char code to actual character (or space if null)
            const ch = if (char_code == 0) ' ' else @as(u8, @intCast(char_code & 0xFF));

            // Get display width of character (1 for ASCII, 2 for CJK, 0 for combining)
            const display_width = getCodePointWidth(char_code);

            // Diff styles
            if (styles != last_style) {
                try writeSgr(&output, styles);
                last_style = styles;

                // Style reset can clear colors, so force color redraw
                if (styles == 0) {
                    last_fg = 255;
                    last_bg = 255;
                }
            }

            // Diff colors
            if (fg != last_fg) {
                try writeFg(&output, fg);
                last_fg = fg;
            }

            if (bg != last_bg) {
                try writeBg(&output, bg);
                last_bg = bg;
            }

            // Write character to output
            try output.append(ch);

            // Update front buffer for next frame's diff
            self.front_buffer[offset] = char_code;
            self.front_buffer[offset + 1] = attr_code;

            // Track cursor position for contiguity checking
            current_x = x + display_width - 1;
            current_y = y;
        }

        return output.toOwnedSlice();
    }
};

/// Get display width of a Unicode code point
/// Fast path for ASCII, CJK detection, combining marks
fn getCodePointWidth(code_point: u32) i32 {
    // Fast path: ASCII and common characters
    if (code_point < 128) {
        return 1;
    }

    // CJK Unified Ideographs and common wide character ranges
    if ((code_point >= 0x1100 and code_point <= 0x115F) or // Hangul Jamo
        (code_point >= 0x2E80 and code_point <= 0xA4CF) or // CJK
        (code_point >= 0xAC00 and code_point <= 0xD7AF) or // Hangul Syllables
        (code_point >= 0xF900 and code_point <= 0xFAFF) or // CJK Compatibility
        (code_point >= 0x20000 and code_point <= 0x2EBEF)) // CJK Extension
    {
        return 2;
    }

    // Zero-width combining marks
    if ((code_point >= 0x0300 and code_point <= 0x036F) or // Combining Diacritical Marks
        (code_point >= 0x1AB0 and code_point <= 0x1AFF) or // Combining Diacritical Marks Extended
        (code_point >= 0x1DC0 and code_point <= 0x1DFF)) // Combining Diacritical Marks Supplement
    {
        return 0;
    }

    // Default to 1 for everything else
    return 1;
}

/// Write cursor movement ANSI sequence
/// Converts 0-based (x, y) to 1-based ANSI row/col
fn writeCursorMove(output: *std.ArrayList(u8), x: u16, y: u16) !void {
    try std.fmt.format(output.writer(), "\x1b[{};{}H", .{ y + 1, x + 1 });
}

/// Write SGR (Select Graphic Rendition) style codes
/// styles byte is a bitmask:
///   bit 0 (1):   Bold
///   bit 1 (2):   Dim
///   bit 2 (4):   Italic
///   bit 3 (8):   Underline
///   bit 4 (16):  Blink
///   bit 5 (32):  Invert
///   bit 6 (64):  Hidden
///   bit 7 (128): Strikethrough
fn writeSgr(output: *std.ArrayList(u8), styles: u8) !void {
    if (styles == 0) {
        try output.appendSlice("\x1b[0m");
        return;
    }
    if (styles & 1 != 0) try output.appendSlice("\x1b[1m");   // Bold
    if (styles & 2 != 0) try output.appendSlice("\x1b[2m");   // Dim
    if (styles & 4 != 0) try output.appendSlice("\x1b[3m");   // Italic
    if (styles & 8 != 0) try output.appendSlice("\x1b[4m");   // Underline
    if (styles & 16 != 0) try output.appendSlice("\x1b[5m");  // Blink
    if (styles & 32 != 0) try output.appendSlice("\x1b[7m");  // Invert
    if (styles & 64 != 0) try output.appendSlice("\x1b[8m");  // Hidden
    if (styles & 128 != 0) try output.appendSlice("\x1b[9m"); // Strikethrough
}

/// Write foreground color ANSI sequence
/// Color 255 is treated as terminal default foreground
/// Other values use 256-color mode
fn writeFg(output: *std.ArrayList(u8), color: u8) !void {
    if (color == 255) {
        try output.appendSlice("\x1b[39m");
    } else {
        try std.fmt.format(output.writer(), "\x1b[38;5;{}m", .{color});
    }
}

/// Write background color ANSI sequence
/// Color 255 is treated as terminal default background
/// Other values use 256-color mode
fn writeBg(output: *std.ArrayList(u8), color: u8) !void {
    if (color == 255) {
        try output.appendSlice("\x1b[49m");
    } else {
        try std.fmt.format(output.writer(), "\x1b[48;5;{}m", .{color});
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// FFI Exports for Bun
// ─────────────────────────────────────────────────────────────────────────────

/// Renderer* renderer_new(u16 width, u16 height)
export fn renderer_new(width: u16, height: u16) ?*Renderer {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer gpa.deinit();

    const renderer = gpa.allocator().create(Renderer) catch return null;
    renderer.* = Renderer.init(gpa.allocator(), width, height) catch {
        gpa.allocator().destroy(renderer);
        return null;
    };
    return renderer;
}

/// void renderer_free(Renderer* ptr)
export fn renderer_free(ptr: ?*Renderer) void {
    if (ptr) |renderer| {
        renderer.deinit();
    }
}

/// void renderer_set_row_offset(Renderer* ptr, u16 offset)
export fn renderer_set_row_offset(ptr: ?*Renderer, offset: u16) void {
    if (ptr) |renderer| {
        renderer.setRowOffset(offset);
    }
}

/// u8* renderer_render_diff(Renderer* ptr, u32* back_buffer, usize buffer_len)
/// Returns pointer to ANSI string (zero-terminated)
export fn renderer_render_diff(
    ptr: ?*Renderer,
    back_buffer: [*]u32,
    buffer_len: usize,
) ?[*]u8 {
    if (ptr == null) return null;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer gpa.deinit();

    const slice = back_buffer[0..buffer_len];
    const result = ptr.?.renderDiff(slice, gpa.allocator()) catch return null;
    return result.ptr;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

test "renderer initialization" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var renderer = try Renderer.init(gpa.allocator(), 80, 24);
    defer renderer.deinit();

    try std.testing.expectEqual(@as(u16, 80), renderer.width);
    try std.testing.expectEqual(@as(u16, 24), renderer.height);
}

test "diff with no changes" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var renderer = try Renderer.init(gpa.allocator(), 10, 10);
    defer renderer.deinit();

    var buffer = try gpa.allocator().alloc(u32, 10 * 10 * 2);
    defer gpa.allocator().free(buffer);

    @memset(buffer, 0);

    // Prime the renderer
    const diff1 = try renderer.renderDiff(buffer, gpa.allocator());
    gpa.allocator().free(diff1);

    // Second diff should be minimal (just the reset)
    const diff2 = try renderer.renderDiff(buffer, gpa.allocator());
    defer gpa.allocator().free(diff2);

    try std.testing.expectEqualStrings("\x1b[0m", diff2);
}

test "code point width detection" {
    try std.testing.expectEqual(@as(i32, 1), getCodePointWidth('A'));
    try std.testing.expectEqual(@as(i32, 1), getCodePointWidth('z'));
    try std.testing.expectEqual(@as(i32, 2), getCodePointWidth('界')); // CJK
}
