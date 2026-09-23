//! TODO

const std = @import("std");
const sdl = @import("../sdl.zig.zon");

const Audio = enum {
    Wasapi,
    DirectSound,
};

pub fn build(b: *std.Build, target: std.Build.ResolvedTarget, mod: *std.Build.Module, upstream: *std.Build.Dependency) !void {
    const audio = b.option(Audio, "audio", "");
    const joystick = b.option(bool, "joystick", "") orelse false;

    const windows_sdk = try std.zig.WindowsSdk.find(b.allocator, b.graph.io, target.result.cpu.arch, &b.graph.environ_map);
    if (windows_sdk.windows10sdk) |sdk| {
        mod.addSystemIncludePath(.{
            .cwd_relative = b.fmt("{s}/include/{s}/winrt", .{ sdk.path, sdk.version }),
        });
    }

    mod.addCSourceFiles(.{
        .root = upstream.path("src"),
        .files = &sdl.windows.common,
    });
    if (audio) |a| {
        switch (a) {
            Audio.Wasapi => {
                mod.addCSourceFiles(.{
                    .root = upstream.path("src"),
                    .files = &sdl.windows.audio.wasapi,
                });
            },
            Audio.DirectSound => {},
        }
    }
    if (joystick) {
        mod.addCSourceFiles(.{
            .root = upstream.path("src"),
            .files = &sdl.windows.joystick,
        });
    }
    mod.addCSourceFiles(.{
        .root = upstream.path("src"),
        .files = &sdl.windows.video,
    });
}
