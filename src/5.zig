const std = @import("std");
const CrateStack = std.atomic.Stack(u8);
const StackList = std.ArrayList(CrateStack);
var aux = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = aux.allocator();

pub fn a(input: []const u8) ![]const u8 {
    // parse stacks
    var stacks: StackList = undefined;
    defer stacks.deinit();
    var line_it = std.mem.split(u8, input, "\n");
    try parseStacks(&stacks, &line_it);

    // parse commands
    while (line_it.next()) |line| {
        var cmds_iter = std.mem.split(u8, line, " ");
        var i: usize = 0;
        var how_many: u32 = undefined;
        var from: u32 = undefined;
        var to: u32 = undefined;
        while (cmds_iter.next()) |cmd| : (i += 1) {
            switch (i) {
                1 => how_many = try std.fmt.parseInt(u32, cmd, 0),
                3 => from = (try std.fmt.parseInt(u32, cmd, 0)) - 1,
                5 => to = (try std.fmt.parseInt(u32, cmd, 0)) - 1,
                else => continue,
            }
        }

        // move between stacks
        i = 0;
        while (i < how_many) : (i += 1) {
            var node = stacks.items[from].pop().?;
            stacks.items[to].push(node);
        }
    }

    // get final answer
    var answer = try std.ArrayList(u8).initCapacity(gpa, stacks.items.len);
    for (stacks.items) |*stack|
        answer.appendAssumeCapacity(stack.pop().?.data);

    return answer.items;
}

fn parseStacks(stacks: *StackList, it: *std.mem.SplitIterator(u8)) !void {
    // get all info above the blank line
    var stacks_input_data = std.ArrayList([]const u8).init(gpa);
    defer stacks_input_data.deinit();
    while (it.next()) |line| {
        if (line.len == 0)
            break;
        try stacks_input_data.append(line);
    }

    // build stacks from info

    // get num of stacks and init list with capacity
    std.mem.reverse([]const u8, stacks_input_data.items);
    const first_line = stacks_input_data.items[0];
    const last_stack_num = &[_]u8{first_line[first_line.len - 2]};
    const num_stacks = try std.fmt.parseInt(u32, last_stack_num, 0);
    stacks.* = try StackList.initCapacity(gpa, num_stacks);

    // init all stacks in list
    var index: usize = 0;
    while (index < num_stacks) : (index += 1)
        try stacks.append(CrateStack.init());

    // fill stacks
    for (stacks_input_data.items[1..]) |line| {
        var i: usize = 1;
        var offset: usize = 1;
        while (i < line.len) : (i += 4) {
            const letter_at_i = line[i];
            var crate_num: u8 = undefined;
            if (letter_at_i == ' ') {
                offset += 3;
                continue;
            } else crate_num = letter_at_i;
            var new_node = try gpa.create(CrateStack.Node);
            new_node.next = undefined;
            new_node.data = crate_num;
            stacks.items[i - offset].push(new_node);
            offset += 3;
        }
    }
}

pub fn b(input: []const u8) ![]const u8 {
    // parse stacks
    var stacks: StackList = undefined;
    defer stacks.deinit();
    var line_it = std.mem.split(u8, input, "\n");
    try parseStacks(&stacks, &line_it);

    // parse commands
    while (line_it.next()) |line| {
        var cmds_iter = std.mem.split(u8, line, " ");
        var i: usize = 0;
        var how_many: u32 = undefined;
        var from: u32 = undefined;
        var to: u32 = undefined;
        while (cmds_iter.next()) |cmd| : (i += 1) {
            switch (i) {
                1 => how_many = try std.fmt.parseInt(u32, cmd, 0),
                3 => from = (try std.fmt.parseInt(u32, cmd, 0)) - 1,
                5 => to = (try std.fmt.parseInt(u32, cmd, 0)) - 1,
                else => continue,
            }
        }

        // insert into temporary list in reverse order
        var tmp = std.ArrayList(*CrateStack.Node).init(gpa);
        i = 0;
        while (i < how_many) : (i += 1)
            try tmp.insert(0, stacks.items[from].pop().?);

        // push onto new stack
        for (tmp.items) |node|
            stacks.items[to].push(node);
    }

    // get final answer
    var answer = try std.ArrayList(u8).initCapacity(gpa, stacks.items.len);
    for (stacks.items) |*stack|
        answer.appendAssumeCapacity(stack.pop().?.data);

    return answer.items;
}

test "5" {
    const input =
        \\    [D]
        \\[N] [C]    
        \\[Z] [M] [P]
        \\ 1   2   3 
        \\
        \\move 1 from 2 to 1
        \\move 3 from 1 to 3
        \\move 2 from 2 to 1
        \\move 1 from 1 to 2
    ;

    try std.testing.expectEqualStrings("CMZ", try a(input));
    try std.testing.expectEqualStrings("MCD", try b(input));
}