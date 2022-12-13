const std = @import("std");
const TreeLineArr = std.ArrayList([]const u8);
const CoordsMap = std.StringArrayHashMap(struct {}); // basically set

pub fn a(input: []const u8) !u32 {
    // init allocator
    //var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //defer _ = gpa.deinit();
    //var alloc = gpa.allocator();
    var alloc = std.heap.c_allocator; // much faster

    // init matrix
    var trees_list = TreeLineArr.init(alloc);
    defer trees_list.deinit();

    // load into matrix
    var it = std.mem.split(u8, input, "\n");
    while (it.next()) |line| try trees_list.append(line);

    // base case
    const trees = trees_list.items;
    if (trees.len < 3 or trees[0].len < 3)
        return 0;

    // put in map to not repeat count when iterating by column
    var coords = CoordsMap.init(alloc);
    defer coords.deinit();

    // iterate by line
    var count: u32 = 0;
    for (trees) |line, y|
        try processLine(alloc, line, y, &coords, &count, true);

    // iterate by column
    for (trees[0]) |_, y| {
        var line = std.ArrayList(u8).init(alloc);
        defer line.deinit();
        for (trees) |tree|
            try line.append(tree[y]);
        try processLine(alloc, line.items, y, &coords, &count, false);
    }

    return count;
}

fn processLine(alloc: std.mem.Allocator, line: []const u8, y: usize, coords: *CoordsMap, count: *u32, line_iter: bool) !void {
    var left_max: u32 = 0;
    var right_max: u32 = 0;
    for (line) |_, x| {
        // starts iteration from right
        const right_x = line.len - 1 - x;

        // if iterating by column invert coordinates so they get the same id
        // memory leak
        var coords_str_list = try alloc.alloc([2]u8, 2);
        coords_str_list[0] = if (line_iter) .{ @intCast(u8, x), @intCast(u8, y) } else .{ @intCast(u8, y), @intCast(u8, x) };
        coords_str_list[1] = if (line_iter) .{ @intCast(u8, right_x), @intCast(u8, y) } else .{ @intCast(u8, y), @intCast(u8, right_x) };

        const left = try std.fmt.parseInt(u32, line[x .. x + 1], 0);
        const right = try std.fmt.parseInt(u32, line[right_x .. right_x + 1], 0);

        if (right_x == x and (left > left_max or right > right_max)) {
            left_max = left;
            right_max = right;
            const new_left_coords = !(try coords.getOrPut(&coords_str_list[0])).found_existing;
            if (new_left_coords) count.* += 1;
            continue;
        }
        if (left > left_max or x == 0) {
            left_max = left;
            const new_left_coords = !(try coords.getOrPut(&coords_str_list[0])).found_existing;
            if (new_left_coords) count.* += 1;
        }
        if (right > right_max or x == 0) {
            right_max = right;
            const new_right_coords = !(try coords.getOrPut(&coords_str_list[1])).found_existing;
            if (new_right_coords) count.* += 1;
        }
    }
}

pub fn b(input: []const u8) !u32 {
    var max: u32 = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var alloc = gpa.allocator();
    //var alloc = std.heap.c_allocator;

    // init matrix
    var trees_list = TreeLineArr.init(alloc);
    defer trees_list.deinit();

    // load into matrix for easier traversal
    var it = std.mem.split(u8, input, "\n");
    while (it.next()) |line|
        try trees_list.append(line);
    const trees = trees_list.items;

    for (trees) |line, y| {
        for (line) |char, x| {
            const center = try std.fmt.parseInt(u32, &[_]u8{char}, 0);

            // look left
            var left_score: u32 = 0;
            var i: i32 = @intCast(i32, x) - 1;
            while (i >= 0) : (i -= 1)
                if (try processChar(line, @intCast(usize, i), center, &left_score))
                    break;

            // look right
            var right_score: u32 = 0;
            i = @intCast(i32, x) + 1;
            while (i < line.len) : (i += 1)
                if (try processChar(line, @intCast(usize, i), center, &right_score))
                    break;

            // look up
            var up_score: u32 = 0;
            i = @intCast(i32, y) - 1;
            while (i >= 0) : (i -= 1)
                if (try processChar(trees[@intCast(usize, i)], @intCast(usize, x), center, &up_score))
                    break;

            // look down
            var down_score: u32 = 0;
            i = @intCast(i32, y) + 1;
            while (i < trees.len) : (i += 1)
                if (try processChar(trees[@intCast(usize, i)], @intCast(usize, x), center, &down_score))
                    break;

            max = @max(max, @intCast(u32, left_score * right_score * down_score * up_score));
        }
    }
    return max;
}

inline fn processChar(line: []const u8, i: usize, center: u32, score: *u32) !bool {
    const this = try std.fmt.parseInt(u32, line[i .. i + 1], 0);
    score.* += 1;
    return if (this >= center) true else false;
}

test "8" {
    const input =
        \\30373
        \\25512
        \\65332
        \\33549
        \\35390
    ;

    try std.testing.expect(try a(input) == 21);
    try std.testing.expect(try b(input) == 8);
}
