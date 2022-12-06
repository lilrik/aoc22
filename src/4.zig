const std = @import("std");

pub fn a(input: []const u8) !u32 {
    var sum: u32 = 0;
    var it = std.mem.split(u8, input, "\n");
    while (it.next()) |line| {
        const pair_split_index = std.ascii.indexOfIgnoreCase(line, ",").?;
        var range1: [2]u32 = undefined;
        var range2: [2]u32 = undefined;
        try parseRange(line[0..pair_split_index], &range1);
        try parseRange(line[pair_split_index + 1 ..], &range2);
        if ((range1[0] <= range2[0] and range1[1] >= range2[1]) or (range2[0] <= range1[0] and range2[1] >= range1[1])) sum += 1;
    }
    return sum;
}

inline fn parseRange(elf_range: []const u8, parsed_range_buffer: []u32) !void {
    const range_split_index = std.ascii.indexOfIgnoreCase(elf_range, "-").?;
    parsed_range_buffer[0] = try std.fmt.parseInt(u32, elf_range[0..range_split_index], 0);
    parsed_range_buffer[1] = try std.fmt.parseInt(u32, elf_range[range_split_index + 1 ..], 0);
}

pub fn b(input: []const u8) !u32 {
    var sum: u32 = 0;
    var it = std.mem.split(u8, input, "\n");
    while (it.next()) |line| {
        const pair_split_index = std.ascii.indexOfIgnoreCase(line, ",").?;
        var range1: [2]u32 = undefined;
        var range2: [2]u32 = undefined;
        try parseRange(line[0..pair_split_index], &range1);
        try parseRange(line[pair_split_index + 1 ..], &range2);
        if ((range1[0] <= range2[0] and range1[1] >= range2[1]) or (range2[0] <= range1[0] and range2[1] >= range1[1])) {
            sum += 1;
            continue;
        }
        if ((range1[1] >= range2[0] and range1[1] <= range2[1]) or (range2[1] >= range1[0] and range2[1] <= range1[1])) sum += 1;
    }
    return sum;
}

test "4" {
    const input =
        \\2-4,6-8
        \\2-3,4-5
        \\5-7,7-9
        \\2-8,3-7
        \\6-6,4-6
        \\2-6,4-8
    ;

    try std.testing.expect(try a(input) == 2);
    try std.testing.expect(try b(input) == 3);
}
