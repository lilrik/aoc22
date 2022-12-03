const std = @import("std");

pub fn a(in_stream: anytype) !u32 {
    var buf: [69]u8 = undefined;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var map = std.AutoHashMap(u8, u8).init(gpa.allocator());
    defer map.deinit();
    var repeated: u8 = undefined;
    var sum: u32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
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

pub fn b(in_stream: anytype) !u32 {
    var buf: [69]u8 = undefined;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var map = std.AutoHashMap(u8, [2]u32).init(gpa.allocator()); // TODO: lookup how to do tuples
    defer map.deinit();
    var sum: u32 = 0;
    var i: u32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (i += 1) {
        const lastLineOfGroup = @mod(i+1, 3) == 0;
        for (line) |c| {
            var appearances = map.get(c) orelse [2]u32{0, i};
            if (appearances[0] == 0 or i > appearances[1]) {
                appearances[0] += 1;
                appearances[1] = i;
                try map.put(c, appearances);
            }
        }
        if (lastLineOfGroup) {
            var it = map.iterator();
            while (it.next()) |entry| {
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
    const in =
        \\vJrwpWtwJgWrhcsFMMfFFhFp
        \\jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
        \\PmmdzqPrVvPwwTWBwg
        \\wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
        \\ttgJtRGJQctTZtZT
        \\CrZsJsPPZsGzwwsLwLmpwMDw
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

    try std.testing.expect(try a(in_stream) == 157);
    try file.seekTo(0);
    try std.testing.expect(try b(in_stream) == 70);
}
