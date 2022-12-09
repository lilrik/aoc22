const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    // open iter dir
    var inputs_iter_dir = try std.fs.cwd().openIterableDir("inputs", .{});
    defer inputs_iter_dir.close();

    // get latest input name (<biggest num>.txt)
    var it = inputs_iter_dir.iterate();
    var latest_file_name: []const u8 = &[_]u8{0}; // placeholder
    while (try it.next()) |entry| {
        const curr_file_name = entry.name;
        if (!std.mem.eql(u8, curr_file_name, "input.txt") and curr_file_name[0] > latest_file_name[0])
            latest_file_name = curr_file_name;
    }

    // inject latest input into input.txt
    const inputs_dir = inputs_iter_dir.dir;
    try std.fs.Dir.copyFile(inputs_dir, latest_file_name, inputs_dir, "input.txt", .{});

    const exe = b.addExecutable("aoc22", "src/main.zig");
    exe.use_stage1 = true; // embed only works with paths outside package in stage1 compiler
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
