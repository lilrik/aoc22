const std = @import("std");

pub fn a(input: []const u8) !u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var map = std.AutoHashMap(u8, u8).init(gpa.allocator());
    defer map.deinit();
    var repeated: u8 = undefined;
    var sum: u32 = 0;

    var it = std.mem.split(u8, input, "\n");
    while (it.next()) |line| {
        for (line[0 .. line.len / 2]) |c| try map.put(c, 1);
        for (line[line.len / 2 ..]) |c| {
            if (map.get(c) orelse 69 == 1) {
                repeated = c;
                break;
            }
        }
        sum += if (repeated > 97) repeated - 96 else repeated - 38;
        map.clearRetainingCapacity();
    }
    return sum;
}

pub fn b(input: []const u8) !u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const Pair = std.meta.Tuple(&[_]type{ u32, u32 });
    var map = std.AutoHashMap(u8, Pair).init(gpa.allocator());
    defer map.deinit();
    var sum: u32 = 0;
    var i: u32 = 0;

    var it = std.mem.split(u8, input, "\n");
    while (it.next()) |line| : (i += 1) {
        const lastLineOfGroup = @mod(i + 1, 3) == 0;
        for (line) |c| {
            var zero: u32 = 0; // because of the comptime error
            var appearances = map.get(c) orelse .{ zero, i };
            if (appearances[0] == 0 or i > appearances[1]) {
                appearances[0] += 1;
                appearances[1] = i;
                try map.put(c, appearances);
            }
        }
        if (lastLineOfGroup) {
            var it2 = map.iterator();
            while (it2.next()) |entry| {
                if (entry.value_ptr.*[0] == 3) {
                    const badge = entry.key_ptr.*;
                    sum += if (badge > 97) badge - 96 else badge - 38;
                    break;
                }
            }
            map.clearRetainingCapacity();
        }
    }
    return sum;
}

test "3" {
    const input =
        \\vJrwpWtwJgWrhcsFMMfFFhFp
        \\jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
        \\PmmdzqPrVvPwwTWBwg
        \\wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
        \\ttgJtRGJQctTZtZT
        \\CrZsJsPPZsGzwwsLwLmpwMDw
    ;

    try std.testing.expect(try a(input) == 157);
    try std.testing.expect(try b(input) == 70);
}
