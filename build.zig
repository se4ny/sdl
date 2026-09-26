const std = @import("std");
const sdl = @import("sdl.zig.zon");
const windows = @import("src/windows.zig");
const linux = @import("src/linux.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
    });

    const mod = b.addModule("sdl", .{
        .target = target,
        .optimize = optimize,
        .link_libcpp = target.result.abi != .msvc,
        .link_libc = true,
    });
    mod.addIncludePath(upstream.path("src"));
    mod.addIncludePath(upstream.path("include"));
    mod.addIncludePath(upstream.path("include/build_config"));

    mod.addCSourceFiles(.{
        .root = upstream.path("src"),
        .files = &sdl.common,
    });

    mod.addCSourceFiles(.{
        .root = upstream.path("src"),
        .files = &sdl.gpu.vulkan,
    });

    if (target.result.abi == .gnu) {
        mod.addIncludePath(upstream.path("src/video/khronos"));
    }

    switch (target.result.os.tag) {
        .windows => {
            try windows.build(b, target, mod, upstream);
        },
        .linux => {
            linux.build(b);
        },
        .macos => {},
        else => {},
    }

    const lib = b.addLibrary(.{
        .name = "sdl3",
        .root_module = mod,
    });

    lib.installHeadersDirectory(upstream.path("include"), ".", .{
        .include_extensions = &.{ ".h", ".hpp" },
    });

    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "tests",
        .root_module = b.addModule("tests", .{
            .optimize = optimize,
            .target = target,
            .link_libc = true,
        }),
    });
    exe.root_module.addCSourceFile(.{
        .file = b.path("tests/main.cpp"),
    });
    exe.root_module.linkLibrary(lib);

    const tests_step = b.step("tests", "");
    tests_step.dependOn(&exe.step);
}
