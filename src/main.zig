const std = @import("std");
const current = @import("2.zig");

pub fn main() !void {
    // get input
    const input = try std.fs.cwd().openFile("input.txt", .{});
    defer input.close();
    var buf_reader = std.io.bufferedReader(input.reader());
    var in_stream = buf_reader.reader();

    // print result
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{d}\n", .{try current.b(&in_stream)});
}

test {
    std.testing.refAllDecls(current);
}