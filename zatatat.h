/*
 * Zatatat - High-performance terminal diff engine
 * C FFI header for Go, Rust, Node.js, and other languages
 *
 * Usage:
 *   1. Link against libzatatat.so (Linux), libzatatat.dylib (macOS), or zatatat.dll (Windows)
 *   2. Include this header
 *   3. Call the functions below
 */

#ifndef ZATATAT_H
#define ZATATAT_H

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Opaque Renderer struct - allocated and managed by FFI layer */
typedef struct Renderer Renderer;

/* Return value from renderer_render_diff containing output string and length */
typedef struct {
    uint8_t* ptr;   /* Pointer to ANSI escape sequence string, or NULL on error */
    size_t len;     /* Length of the string in bytes */
} OutputSlice;

/*
 * Create a new renderer for the given terminal dimensions.
 *
 * Args:
 *   width: Terminal width in columns (e.g., 80)
 *   height: Terminal height in rows (e.g., 24)
 *
 * Returns:
 *   Renderer* on success, NULL on allocation failure
 *
 * Example:
 *   Renderer* r = renderer_new(80, 24);
 *   if (!r) { /* handle error */ }
 */
Renderer* renderer_new(uint16_t width, uint16_t height);

/*
 * Free a renderer and all associated resources.
 *
 * Args:
 *   ptr: Renderer pointer from renderer_new(), or NULL (safe no-op)
 *
 * Example:
 *   renderer_free(r);
 */
void renderer_free(Renderer* ptr);

/*
 * Set the row offset for rendering to a sub-region of the terminal.
 *
 * Useful for split panes or status bars that don't start at row 0.
 *
 * Args:
 *   ptr: Renderer pointer
 *   offset: Number of rows to offset all cursor positioning by
 *
 * Example:
 *   renderer_set_row_offset(r, 5);  // Render starting at row 5
 */
void renderer_set_row_offset(Renderer* ptr, uint16_t offset);

/*
 * Diff the current frame against the previous frame and return ANSI codes.
 *
 * The buffer format is:
 *   buffer[i*2]     = character code (Unicode code point as uint32_t)
 *   buffer[i*2 + 1] = (styles << 16) | (bg << 8) | fg
 *
 * Cell attributes:
 *   fg (bits 0-7):      Foreground color (ANSI 256, 255 = default)
 *   bg (bits 8-15):     Background color (ANSI 256, 255 = default)
 *   styles (bits 16-23): Text styles bitmask
 *                        1=bold, 2=dim, 4=italic, 8=underline,
 *                        16=blink, 32=inverse, 64=hidden, 128=strikethrough
 *   reserved (bits 24-31): Must be 0
 *
 * Args:
 *   ptr: Renderer pointer
 *   buffer: Pointer to cell buffer (uint32_t array)
 *   buffer_len: Length of buffer in uint32_t elements (width * height * 2)
 *
 * Returns:
 *   OutputSlice with .ptr pointing to ANSI string and .len with its length.
 *   .ptr is NULL on error (invalid renderer, allocation failure).
 *   Caller MUST free the returned string via renderer_free_output().
 *
 * Example:
 *   uint32_t buffer[80 * 24 * 2];
 *   // ... fill buffer with cells ...
 *   OutputSlice output = renderer_render_diff(r, buffer, 80 * 24 * 2);
 *   if (output.ptr) {
 *       fwrite(output.ptr, 1, output.len, stdout);
 *       renderer_free_output(output.ptr, output.len);
 *   }
 */
OutputSlice renderer_render_diff(Renderer* ptr, uint32_t* buffer, size_t buffer_len);

/*
 * Free the ANSI output string returned by renderer_render_diff().
 *
 * Args:
 *   ptr: Pointer returned by renderer_render_diff(), or NULL (safe no-op)
 *   len: Length of the string (from OutputSlice.len)
 *
 * CRITICAL: The length MUST match the length returned by renderer_render_diff().
 *           Do not attempt to find the length by searching for null terminator.
 *
 * Example:
 *   OutputSlice output = renderer_render_diff(r, buffer, len);
 *   if (output.ptr) {
 *       write_to_terminal(output.ptr, output.len);
 *       renderer_free_output(output.ptr, output.len);  // Exact length!
 *   }
 */
void renderer_free_output(uint8_t* ptr, size_t len);

#ifdef __cplusplus
}
#endif

#endif /* ZATATAT_H */
