const std = @import("std");
const diff = @import("diff.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Create renderer for 80x24 terminal
    const renderer = try diff.Renderer.init(allocator, 80, 24);
    defer renderer.deinit();

    // Allocate buffer (width * height * 2 u32 values)
    const buffer = try allocator.alloc(u32, 80 * 24 * 2);
    defer allocator.free(buffer);

    // Clear buffer
    @memset(buffer, 0);

    // Write some cells
    // buffer[i*2] = character code
    // buffer[i*2+1] = (styles << 16) | (bg << 8) | fg

    // Cell (0,0): 'H' white bold
    buffer[0] = 'H';
    buffer[1] = (1 << 16) | (255 << 8) | 15; // bold, default bg, white fg

    // Cell (1,0): 'e' white
    buffer[2] = 'e';
    buffer[3] = (255 << 8) | 15; // no style, default bg, white

    // Cell (2,0): 'l' white
    buffer[4] = 'l';
    buffer[5] = (255 << 8) | 15;

    // Cell (3,0): 'l' white
    buffer[6] = 'l';
    buffer[7] = (255 << 8) | 15;

    // Cell (4,0): 'o' white
    buffer[8] = 'o';
    buffer[9] = (255 << 8) | 15;

    // Generate diff (ANSI escape sequence)
    const output1 = try renderer.renderDiff(buffer, allocator);
    defer allocator.free(output1);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("First frame diff:\n", .{});
    try stdout.print("  Length: {d} bytes\n", .{output1.len});
    try stdout.print("  Contains reset: {}\n", .{std.mem.indexOf(u8, output1, "\x1b[0m") != null});
    try stdout.print("  Contains 'Hello': {}\n", .{std.mem.indexOf(u8, output1, "Hello") != null});

    // Second diff with no changes should be minimal
    const output2 = try renderer.renderDiff(buffer, allocator);
    defer allocator.free(output2);

    try stdout.print("\nSecond frame diff (no changes):\n", .{});
    try stdout.print("  Length: {d} bytes\n", .{output2.len});
    try stdout.print("  Just reset: {}\n", .{std.mem.eql(u8, output2, "\x1b[0m")});

    // Modify cell (0,0) to red
    buffer[1] = (1 << 16) | (255 << 8) | 1; // bold, default bg, red fg

    const output3 = try renderer.renderDiff(buffer, allocator);
    defer allocator.free(output3);

    try stdout.print("\nThird frame diff (color change):\n", .{});
    try stdout.print("  Length: {d} bytes\n", .{output3.len});
    try stdout.print("  Contains color code: {}\n", .{std.mem.indexOf(u8, output3, "\x1b[38;5;1m") != null});
}
