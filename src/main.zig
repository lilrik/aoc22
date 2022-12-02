const std = @import("std");
const one = @import("1.zig");

const inputPath = "./inputs/";

pub fn main() !void {
    // get input
    const input = try std.fs.cwd().openFile(inputPath ++ "1.txt", .{});
    defer input.close();
    var buf_reader = std.io.bufferedReader(input.reader());
    var in_stream = buf_reader.reader();

    // print result
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{d}\n", .{try one.b(&in_stream)});
}
