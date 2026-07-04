# Zatatat — AI Navigation Guide

> **This file is the project constitution.** It's symlinked from `../CLAUDE.md` so Claude Code loads it in every session.
> Do not edit CLAUDE.md directly — edit this file instead.
> Procedures belong in `.claude/skills/`, not here.

---

## Project Overview

**What:** A high-performance terminal diff engine in Zig—20–50µs per frame, zero dependencies, zero overhead.
**Why:** Enables responsive terminal UIs by efficiently comparing cell buffers and emitting minimal ANSI escape sequences. Solves the performance ceiling of string-based rendering (Ink, Rich) by working at the cell level instead.
**Status:** Production-ready. Fully tested, documented, and deployed.
**Repo:** github.com/killallservers/zatatat

---

## Tech Stack

| Layer      | Technology                          | Notes                                     |
|------------|-------------------------------------|-------------------------------------------|
| Language   | Zig                                 | Systems programming; zero-cost abstractions; compile-time optimization |
| Build      | Zig Build System                    | build.zig; ReleaseFast optimization      |
| Testing    | Zig Test Runner                     | Built-in; no external test framework      |
| Docs       | Markdown                            | README.md, ARCHITECTURE.md for reference |
| Distribution| Library + FFI exports              | Pure Zig library, C interface for FFI (Go, Rust, Node via Bun) |

---

## Repository Structure

```
zatatat/
├── src/
│   ├── diff.zig              # Core renderer (300 lines; fully commented)
│   └── ...                   # Other library modules as needed
├── build.zig                 # Zig build configuration
├── build.zig.zon             # Dependency manifest
├── example.zig               # Usage example and demo
├── docs/
│   ├── llm.md                # This file (CLAUDE.md symlink)
│   ├── architecture.md       # System overview (symlinked to CLAUDE.md)
│   ├── decisions.md          # Architectural Decision Records
│   ├── testing.md            # Test strategy
│   ├── constraints.md        # Hard constraints
│   ├── deployment.md         # Deployment guide (informational)
│   └── context.md            # Domain language
├── README.md                 # Project overview and quick start
├── ARCHITECTURE.md           # Deep-dive: memory model, FFI, performance
├── README_ZIG.md             # API reference and design notes
├── ZIG_DESIGN.md             # Algorithm and design decisions
└── CHANGELOG.md              # Version history
```

---

## Coding Conventions

- **Zig style:** snake_case for functions/variables, PascalCase for types and structs
- **Filenames:** snake_case (e.g., `diff.zig`, not `Diff.zig`)
- **Comments:** Only document non-obvious behavior, design rationale, and performance notes. Omit comments restating what the code does (good naming is enough)
- **No dependencies:** Zero external crates or libraries (except Zig stdlib)
- **Memory:** Allocator is always passed as parameter; no global allocators
- **Performance:** Inline utility functions for hot paths; benchmark-driven optimization
- **Testing:** Test files co-located with source (e.g., `diff.zig` → tests in same file)
- **Build:** Always use `zig build` or `build.zig`; respect the build configuration

---

## Architecture Principles

1. **Single-pass cell diffing** — O(width × height) complexity; can't be faster than reading the buffer once
2. **Minimal branching** — Sequential memory access for CPU cache efficiency
3. **Zero-copy guarantees** — FFI callers pass pointer directly; Zig reads/writes same bytes
4. **Inline ANSI generation** — No tokenization, no rebuilding—emit codes during diff
5. **Pre-allocated output** — No allocations in hot path; use caller's allocator for output string
6. **Contiguity tracking** — Minimize cursor movement codes by tracking position
7. **Continuation cells** — Track wide glyphs (CJK characters) with continuation markers
8. **No allocations in library** — Renderer struct is allocated by caller; output string uses caller's allocator

---

## Hard Constraints

- **Zero dependencies** — Never add external crates. Use Zig stdlib only
- **No breaking changes to cell format** — All integration code relies on the (char, attr) layout; changes cascade widely
- **FFI exports are permanent** — C interface is public API; once `export fn` exists, maintain binary compatibility
- **Performance budget:** 20–50µs per 80×24 frame (5% dirty cells) — profile before committing hot-path changes
- **Never commit secrets, tokens, or credentials** — Use `.env` or config for runtime secrets
- **Memory safety** — Zig's safety checks must pass; no `@intCast`, `@ptrCast`, etc. without justification
- **Test everything new** — All public functions must have corresponding tests

---

## Key Contacts & Decisions

- Decisions log: `docs/decisions.md`
- Open specs: `.claude/specs/`
- Architecture doc: `docs/architecture.md`

---

## Skills Available

| Skill          | When to invoke                                                      |
|----------------|---------------------------------------------------------------------|
| `/tdd`         | Adding features or fixing bugs; tests as the driver                 |
| `/diagnose`    | Stuck on a performance regression or unexpected behavior            |
| `/zoom-out`    | Before a refactor; losing the big picture on algorithm details      |
| `/decision`    | Logging architectural decisions (e.g., new cell format, API changes) |
| `/code-review` | Before committing hot-path changes; verify performance didn't degrade |
| `/verify`      | After changes that could affect rendering output or timing          |

---

*Last updated: 2026-07-04*
