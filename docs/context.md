# Zatatat — Domain Language

> Shared vocabulary for the AI agent and the team.

---

## Core Concepts

| Term | Definition |
|------|-----------|
| **Cell** | A single position on the terminal screen. Holds a character code and attributes (color, style). Two u32 values in the buffer. |
| **Buffer** | A flat Uint32Array representing the entire screen. Size = width × height × 2 (each cell is 2 u32s). |
| **Front buffer** | The previous frame's state, stored in the Renderer. Used for diffing against the current frame. |
| **Back buffer** | The current frame being rendered. Passed to `renderDiff()`. |
| **Diff** | The set of cells that changed from front to back. Only these emit ANSI codes. |
| **Render** | Process of comparing buffers, emitting ANSI codes, and returning the escape sequence string. |
| **ANSI code** | Escape sequence (e.g., `\x1b[38;5;15m` for color). Generated inline during diff. |

## Domain Objects

| Term | Definition |
|------|-----------|
| **Renderer** | Struct holding width, height, front_buffer, and row_offset. Stateful; tracks the previous frame. |
| **Cell attributes** | The u32 at buffer[i*2+1]. Packs foreground, background, and styles into 24 bits. |
| **Continuation cell** | A cell marking the tail of a wide glyph (CJK). Char code = 0x0011_0000. |
| **Cursor position** | (x, y) on the terminal, 0-indexed. Used for cursor move codes. |
| **Contiguity** | Whether the next changed cell is adjacent to the previous (no cursor move needed). |

## States

| Term | Definition |
|------|-----------|
| **No changes** | All cells in buffer match front_buffer. Output is just reset code (`\x1b[0m`). |
| **Sparse dirty** | Few cells changed (e.g., 5%). Most of the diff loop skips unchanged cells. |
| **Dense dirty** | Many cells changed. Loop emits more codes; still O(cells) but higher constant factor. |
| **Full redraw** | All cells changed. Maximum ANSI output; ~150µs per frame. |

## Abbreviations

| Abbrev | Expands to |
|--------|------------|
| **FFI** | Foreign Function Interface — calling Zig from other languages via C ABI |
| **SGR** | Select Graphic Rendition — ANSI codes for styles (bold, italic, etc.) |
| **CJK** | Chinese, Japanese, Korean — wide characters requiring continuation cells |
| **GPA** | GeneralPurposeAllocator — Zig's flexible heap allocator |
| **TUI** | Terminal User Interface — interactive text-based application |

---

*Last updated: 2026-07-04*
