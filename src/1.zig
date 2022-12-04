const std = @import("std");

pub fn a(input: []const u8) !u32 {
    var sum: u32 = 0;
    var max: u32 = 0;

    var it = std.mem.split(u8, input, "\n");
    while (it.next()) |line| {
        if (line.len == 0) {
            max = @max(sum, max);
            sum = 0;
            continue;
        }
        sum += try std.fmt.parseInt(u32, line, 0);
    }
    return max;
}

pub fn b(input: []const u8) !u32 {
    var sum: u32 = 0;
    var maxs = [_]u32{0} ** 3;

    var it = std.mem.split(u8, input, "\n");
    while (it.next()) |line| {
        if (line.len == 0) {
            addToTop3(&maxs, sum);
            sum = 0;
            continue;
        }
        sum += try std.fmt.parseInt(u32, line, 0);
    }
    addToTop3(&maxs, sum);
    const maxs_vec: @Vector(maxs.len, u32) = maxs;
    return @reduce(.Add, maxs_vec);
}

fn addToTop3(maxs: []u32, sum: u32) void {
    var left: i32 = -1;
    for (maxs) |*valptr| {
        const val = valptr.*;
        if (left >= 0) {
            valptr.* = @intCast(u32, left);
            left = @intCast(i32, val);
            continue;
        }
        if (sum > val) {
            left = @intCast(i32, val);
            valptr.* = sum;
        }
    }
}

test "1" {
    const input =
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

    try std.testing.expect(try a(input) == 24000);
    try std.testing.expect(try b(input) == 45000);
}
