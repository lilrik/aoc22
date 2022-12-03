const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    // inject latest input from ./inputs into input.txt
    const inputsDir = "./inputs";
    var currDir = std.fs.cwd();
    //defer currDir.close();
    var dir = try currDir.openIterableDir(inputsDir, .{});
    defer dir.close();
    var it = dir.iterate();
    var max = (try it.next()).?;
    while (try it.next()) |entry| max = if (entry.name[0] > max.name[0]) entry else max;
    try std.fs.Dir.copyFile(try currDir.openDir(inputsDir, .{}), max.name, currDir, "input.txt", .{});

    const exe = b.addExecutable("aoc22", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
