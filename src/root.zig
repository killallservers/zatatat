//! Zatatat - Terminal diff engine
//! Pure Zig implementation of single-pass cell-by-cell diffing.
//!
//! Public API exports:
//! - Renderer struct with init(), deinit(), renderDiff(), setRowOffset()
//! - OutputSlice struct for FFI return values
//! - FFI functions for C interop (Go, Rust, Node.js via Bun)

pub const diff = @import("diff.zig");
pub const Renderer = diff.Renderer;
pub const OutputSlice = diff.OutputSlice;

// Re-export FFI functions
pub const renderer_new = diff.renderer_new;
pub const renderer_free = diff.renderer_free;
pub const renderer_set_row_offset = diff.renderer_set_row_offset;
pub const renderer_render_diff = diff.renderer_render_diff;
pub const renderer_free_output = diff.renderer_free_output;
