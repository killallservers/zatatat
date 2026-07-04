# Constraints

Hard constraints for this codebase. Respect unconditionally.

---

## Never Do

### Algorithm
- Do not change the cell format without bumping a major version — all callers rely on it
- Do not break FFI exports — once `export fn` exists, maintain binary compatibility
- Do not allocate memory inside the diff loop — pre-allocate or use caller's allocator

### Code
- Do not add external dependencies (crates, libraries) — use Zig stdlib only
- Do not use `@intCast`, `@ptrCast`, or other unsafe casts without a comment explaining why
- Do not commit secrets, tokens, or credentials of any kind
- Do not modify Zig stdlib or build system without explicit justification
- Do not ignore compiler warnings — they catch real bugs

### Performance
- Do not commit changes that push frame time above 50µs (on typical hardware) — performance is a feature
- Do not optimize prematurely; always benchmark first
- Do not assume CPU behavior — profile with `perf` or `Instruments`

## Always Do

- Test new code — all public functions must have tests
- Document non-obvious algorithm details in comments
- Keep `docs/llm.md` (CLAUDE.md) factual and up-to-date
- Verify FFI exports work from target languages (Go, Rust, Node) before merging
- Profile hot-path changes before committing
- Bump version in CHANGELOG.md when merging features or fixes

## Performance Budget

Frame rendering time (80×24 screen):
- **Target:** 20–50µs (5% dirty cells)
- **Acceptable:** Up to 100µs (still <2% CPU at 60 FPS)
- **Unacceptable:** >150µs (exceeds CPU budget; investigate)

Profile with `perf record` (Linux) or `Instruments` (macOS).

## Build Constraints

- Build always with `zig build -Doptimize=ReleaseFast` for production
- ReleaseFast enables aggressive optimization; debug builds are 10x slower
- Shared library must be PIC (position-independent code); build.zig sets `.pic = true`
- Strip debug symbols in production builds to reduce binary size

## Testing Constraints

- All tests must pass on first run — no flakes
- Tests must be deterministic (no randomness unless seeded)
- No timeouts in tests — diff is fast enough that tests finish instantly

---

*Last updated: 2026-07-04*
