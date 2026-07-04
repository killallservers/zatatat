# Testing

## Strategy

**Unit + integration tests only.** No mocks; all tests exercise the real diff algorithm.

Core principle: Test the algorithm thoroughly. No external services, no mocks—just Zig code and real buffers.

## Tools

| Layer | Tool | Notes |
|-------|------|-------|
| Unit / Integration | Zig Test Runner | Built-in; `zig build test` |
| Coverage | Not automated | Manual inspection of test cases |

## Running Tests

```bash
# All tests
zig build test

# Run example to see it in action
zig build run
```

## Test Organization

Tests are inline in `src/diff.zig` (Zig convention). Each test block verifies a specific behavior:

```zig
test "initialization" {
    // Verify Renderer.init() works
}

test "diff with no changes" {
    // First diff, then second diff on unchanged buffer
    // Expect minimal output
}

test "diff detects color changes" {
    // Fill buffer with same char, different colors
    // Expect color codes in output
}

// ... more tests
```

## Conventions

- Test names describe the scenario (e.g., `"diff detects style changes"`)
- Use domain language from `docs/context.md` in assertions
- Tests pass real buffers; no mocking the Renderer
- Each test is independent; order doesn't matter
- Assertions are explicit (use `try expect()` from std.testing)

## What Must Always Be Tested

- `Renderer.init()` — allocation and initialization
- `renderDiff()` with no changes — should output just reset
- `renderDiff()` with cell changes — should detect diffs
- Style changes — bold, italic, underline, etc.
- Color changes — foreground, background
- Cursor movement — contiguity tracking
- Unicode detection — character width detection
- Multi-frame rendering — front_buffer updates correctly

## Performance Expectations

Tests run in microseconds. If a test takes >100ms, something is wrong (usually an infinite loop).

---

*Last updated: 2026-07-04*
