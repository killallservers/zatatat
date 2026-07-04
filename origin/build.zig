const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Library: compile diff.zig as a reusable library
    const lib = b.addStaticLibrary(.{
        .name = "terminal_renderer",
        .root_source_file = b.path("src/diff.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    // Tests
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/diff.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_lib_unit_tests.step);

    // Benchmark (if you have src/bench.zig)
    // const bench = b.addExecutable(.{
    //     .name = "bench",
    //     .root_source_file = b.path("src/bench.zig"),
    //     .target = target,
    //     .optimize = optimize,
    // });
    // const run_bench = b.addRunArtifact(bench);
    // const bench_step = b.step("bench", "Run benchmarks");
    // bench_step.dependOn(&run_bench.step);
}
