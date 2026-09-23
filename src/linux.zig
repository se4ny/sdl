const std = @import("std");

const Audio = enum {
    Pipewire,
};

pub fn build(b: *std.Build) void {
    const audio = b.option(Audio, "audio", "");

    if (audio) |a| {
        std.log.warn("{}", .{a});
    }
}
