const std = @import("std");

pub fn a(in_stream: anytype) !u32 {
    var buf: [69]u8 = undefined;
    var sum: u32 = 0;
    var max: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            max = @max(sum, max);
            sum = 0;
            continue;
        }
        sum += try std.fmt.parseInt(u32, line, 0);
    }

    return max;
}

pub fn b(in_stream: anytype) !u32 {
    var buf: [69]u8 = undefined;
    var sum: u32 = 0;
    var maxs = [_]u32{0} ** 3;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            auxB(&maxs, &sum);
            sum = 0;
            continue;
        }
        sum += try std.fmt.parseInt(u32, line, 0);
    }
    auxB(&maxs, &sum);

    var total: u32 = 0;
    inline for (maxs) |val| total += val;
    return total;
}

fn auxB(maxs: []u32, psum: *u32) void {
    var sum = psum.*;
    var left: i32 = -1;
    for (maxs) |val, i| {
        if (left >= 0) {
            maxs[i] = @intCast(u32, left);
            left = @intCast(i32, val);
            continue;
        }
        if (sum > val) {
            left = @intCast(i32, val);
            maxs[i] = sum;
        }
    }
}

test "1" {
    const in =
        \\1000
        \\2000
        \\3000
        \\
        \\4000
        \\
        \\5000
        \\6000
        \\
        \\7000
        \\8000
        \\9000
        \\
        \\10000
    ;

    const currDir = std.fs.cwd();
    const path = "tmp";
    try currDir.writeFile(path, in);
    defer currDir.deleteFile(path) catch |err| {
        std.debug.print("{}", .{err});
    };
    const file = try currDir.openFile(path, .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    try std.testing.expect(try a(in_stream) == 24000);
    try file.seekTo(0);
    try std.testing.expect(try b(in_stream) == 45000);
}
