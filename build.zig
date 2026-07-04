const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Zatatat module (library)
    const zatatat_module = b.addModule("zatatat", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // ─────────────────────────────────────────────────────────────────────
    // Shared Library (for FFI: Go, Rust, Node.js via Bun, etc.)
    // ─────────────────────────────────────────────────────────────────────

    const lib = b.addLibrary(.{
        .name = "zatatat",
        .root_module = zatatat_module,
        .linkage = .dynamic,
    });

    if (optimize == .ReleaseFast or optimize == .ReleaseSmall) {
        lib.root_module.strip = true; // Remove debug symbols in release builds
    }

    b.installArtifact(lib);

    // Main executable (example)
    const exe = b.addExecutable(.{
        .name = "zatatat",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "zatatat", .module = zatatat_module },
            },
        }),
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Unit tests
    const lib_unit_tests = b.addTest(.{
        .root_module = zatatat_module,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
