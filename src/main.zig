const std = @import("std");

const inputPath = "./inputs/";

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{d}\n", .{try oneB()});
}

pub fn oneA() !u32 {
    const input = try std.fs.cwd().openFile(inputPath ++ "1.txt", .{});
    defer input.close();

    var buf_reader = std.io.bufferedReader(input.reader());
    var in_stream = buf_reader.reader();

    var buf: [10]u8 = undefined;
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

pub fn oneB() !u32 {
    const input = try std.fs.cwd().openFile(inputPath ++ "1.txt", .{});
    defer input.close();

    var buf_reader = std.io.bufferedReader(input.reader());
    var in_stream = buf_reader.reader();

    var buf: [10]u8 = undefined;
    var sum: u32 = 0;
    var maxs = [_]u32{0} ** 3;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            aux(&maxs, &sum);
            sum = 0;
            continue;
        }
        sum += try std.fmt.parseInt(u32, line, 0);
    }
    aux(&maxs, &sum);

    var total: u32 = 0;
    inline for (maxs) |val| total += val;
    return total;
}

fn aux(maxs: []u32, psum: *u32) void {
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
