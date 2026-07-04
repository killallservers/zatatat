# Distribution & Deployment

Zatatat is a library, not a service. Distribution means making the compiled binary available to users.

## Building for Release

```bash
# Library (shared object)
zig build -Doptimize=ReleaseFast
# Output: zig-cache/lib/libzatatat.so (Linux)
#         zig-cache/lib/libzatatat.dylib (macOS)
#         zig-cache/lib/libzatatat.dll (Windows)

# Standalone binary (if adding a CLI)
zig build-exe example.zig -O ReleaseFast
# Output: ./example (executable)
```

## Publishing

### As Zig Package

```bash
# Update build.zig.zon with new version
# Tag release: git tag v1.0.0
# Push: git push origin v1.0.0
```

Consumers add to their `build.zig.zon`:
```zig
.zatatat = .{
    .url = "https://github.com/killallservers/zatatat/archive/refs/tags/v1.0.0.tar.gz",
    .hash = "...",
}
```

### As Compiled Binary

For users who want pre-built `.so`, `.dylib`, `.dll`:

- GitHub Releases: Attach binaries (x86_64-linux, aarch64-linux, x86_64-macos, aarch64-macos, x86_64-windows, aarch64-windows)
- Per-platform CI: Use GitHub Actions matrix to build on each OS

```yaml
# .github/workflows/release.yml
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest, windows-latest]
    arch: [x86_64, aarch64]
```

### As FFI Library for Other Languages

**Go:**
```bash
# Copy .so to vendor or point to installed location
# Callers use: `// #cgo LDFLAGS: -L/usr/local/lib -lzatatat`
```

**Rust:**
```bash
# Publish crate with build.rs that links to .a (static lib)
```

**Node.js (Bun):**
```bash
# npm publish prebuilt binaries or source + build-on-install
```

## Version Management

- **Semantic versioning:** MAJOR.MINOR.PATCH
- **Major:** Breaking API changes (e.g., cell format change)
- **Minor:** New features (e.g., true color support)
- **Patch:** Bug fixes

Update:
- `build.zig.zon` — version string
- `CHANGELOG.md` — release notes
- Git tags — match versions

## Backwards Compatibility

Once an FFI export exists (`export fn`), it's part of the public API. Changing signatures breaks consumers.

Safe changes:
- Adding new functions
- Adding parameters with default values (Zig feature)
- Internal optimizations (no API change)

Unsafe changes:
- Renaming functions
- Changing parameter order or types
- Removing functions
- Changing cell format

When backward compatibility breaks, bump MAJOR version.

## No CI/CD Required

Zatatat is a library. There's no service to deploy or health check.

**Optional automation:** GitHub Actions to run `zig build test` on every push/PR and build release binaries.

---

*Last updated: 2026-07-04*
