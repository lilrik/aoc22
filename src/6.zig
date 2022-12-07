const std = @import("std");

pub fn a(input: []const u8) !u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();
    var map = std.AutoArrayHashMap(u8, u8).init(alloc);
    defer map.deinit();

    const non_eql_target = 4;
    var non_eql_count: i32 = 0;
    for (input) |c, i| {
        const to_remove_index = @intCast(i32, i) - non_eql_target;
        if (to_remove_index >= 0) {
            const key_to_remove = input[@intCast(usize, to_remove_index)];
            const num = map.get(key_to_remove).?;
            try map.put(key_to_remove, num - 1);
            if (num - 1 == 0) non_eql_count -= 1;
        }

        const num = map.get(c) orelse 0;
        if (num == 0) non_eql_count += 1;
        try map.put(c, num + 1);

        if (non_eql_count == non_eql_target) return @intCast(u32, i + 1);
    }

    unreachable;
}

pub fn b(input: []const u8) !u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();
    var map = std.AutoArrayHashMap(u8, u8).init(alloc);
    defer map.deinit();

    const non_eql_target = 14;
    var non_eql_count: i32 = 0;
    for (input) |c, i| {
        const to_remove_index = @intCast(i32, i) - non_eql_target;
        if (to_remove_index >= 0) {
            const key_to_remove = input[@intCast(usize, to_remove_index)];
            const num = map.get(key_to_remove).?;
            try map.put(key_to_remove, num - 1);
            if (num - 1 == 0) non_eql_count -= 1;
        }

        const num = map.get(c) orelse 0;
        if (num == 0) non_eql_count += 1;
        try map.put(c, num + 1);

        if (non_eql_count == non_eql_target) return @intCast(u32, i + 1);
    }

    unreachable;
}

test "6" {
    const InputResPair = std.meta.Tuple(&[_]type{ []const u8, u32 });

    const input_and_res_a = [_]InputResPair{
        .{ "bvwbjplbgvbhsrlpgdmjqwftvncz", 5 },
        .{ "nppdvjthqldpwncqszvftbrmjlhg", 6 },
        .{ "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 10 },
        .{ "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 11 },
    };
    const input_and_res_b = [_]InputResPair{
        .{ "mjqjpqmgbljsphdztnvjfqwrcgsmlb", 19 },
        .{ "bvwbjplbgvbhsrlpgdmjqwftvncz", 23 },
        .{ "nppdvjthqldpwncqszvftbrmjlhg", 23 },
        .{ "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 29 },
        .{ "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 26 },
    };

    for (input_and_res_a) |pair|
        try std.testing.expect(try a(pair[0]) == pair[1]);
    for (input_and_res_b) |pair|
        try std.testing.expect(try b(pair[0]) == pair[1]);
}
