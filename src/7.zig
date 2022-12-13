const std = @import("std");

const FilenameFilesizeMap = std.StringArrayHashMap(u32);
const DirNodeMap = std.StringArrayHashMap(*DirNode);

const Keywords = enum {
    cd,
    ls,
    dir,
    @"/",
    @"..",
    @"$",
    // in theory, all other possible symbols but, in practice, only numbers
    num,

    // stage 1 compiler bug if using return with block
    fn nameCastRuntime(token: []const u8) Keywords {
        inline for (@typeInfo(Keywords).Enum.fields) |field| {
            const field_name = field.name;
            if (std.mem.eql(u8, token, field_name))
                return @field(Keywords, field_name);
        }
        return .num;
    }
};

const DirNode = struct {
    name: []const u8,
    parent: *DirNode,
    files: ?FilenameFilesizeMap = null,
    children: ?DirNodeMap = null,
    allocator: *std.mem.Allocator,

    // recursive deinit for entire tree including root node
    fn deinit(self: *@This()) void {
        if (self.files) |*f|
            f.deinit();

        if (self.children) |*c| {
            for (c.values()) |child| {
                child.deinit();
                self.allocator.destroy(child);
            }
            c.deinit();
        }

        if (self.isRoot())
            self.allocator.destroy(self);

        return;
    }

    inline fn isRoot(self: *@This()) bool {
        return self == self.parent;
    }

    fn size(self: *const @This()) u32 {
        var sum: u32 = 0;
        if (self.files) |files| {
            for (files.values()) |file_size| {
                sum += file_size;
            }
        }
        if (self.children) |children| {
            for (children.values()) |child| {
                sum += child.size();
            }
        }
        return sum;
    }
};

pub fn a(input: []const u8) !u32 {
    // init allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var alloc = gpa.allocator();

    // init root node
    var root_node = try alloc.create(DirNode);
    root_node.* = .{
        .name = "/",
        .parent = undefined,
        .allocator = &alloc,
    };
    root_node.parent = root_node;
    defer root_node.deinit();

    // parse input
    var curr_node = root_node;
    var it = std.mem.split(u8, input, "\n");
    while (it.next()) |line|
        try parseLine(line, root_node, &curr_node, &alloc);

    return calcFinalAnsA(root_node);
}

fn parseLine(line: []const u8, root_node: *DirNode, curr_node_ptr: **DirNode, alloc: *std.mem.Allocator) !void {
    var cmd_it = std.mem.tokenize(u8, line, " ");
    while (cmd_it.next()) |token| {
        var curr_node = curr_node_ptr.*;
        switch (Keywords.nameCastRuntime(token)) {
            .cd => {
                // cd with no args is not possible here
                const dir_name = cmd_it.next().?;
                curr_node_ptr.* = switch (Keywords.nameCastRuntime(dir_name)) {
                    .@"/" => root_node,
                    .@".." => curr_node.parent,
                    // cd only happens after dir is "known"
                    else => curr_node.children.?.get(dir_name).?,
                };
            },
            .dir => {
                // dir always has a name
                const dir_name = cmd_it.next().?;
                if (curr_node.children == null)
                    curr_node.children = DirNodeMap.init(alloc.*);
                var entry = try curr_node.children.?.getOrPut(dir_name);
                if (!entry.found_existing) {
                    var new_node = try alloc.create(DirNode);
                    new_node.* = .{ .name = dir_name, .parent = curr_node, .allocator = alloc };
                    entry.value_ptr.* = new_node;
                }
                break;
            },
            .num => {
                // filesize always has correspondent filename
                const filename = cmd_it.next().?;
                if (curr_node.files == null)
                    curr_node.files = FilenameFilesizeMap.init(alloc.*);
                // previous statement assures it's never null
                var entry = try curr_node.files.?.getOrPut(filename);
                if (!entry.found_existing)
                    entry.value_ptr.* = try std.fmt.parseInt(u32, token, 0);
            },
            .ls => break,
            .@"$" => continue,
            else => unreachable,
        }
    }
}

fn calcFinalAnsA(node: *DirNode) u32 {
    var sum: u32 = 0;

    var children_ptrs: []*DirNode = undefined;
    children_ptrs = if (node.children) |children|
        children.values()
    else
        &[_]*DirNode{};
    for (children_ptrs) |child|
        sum += calcFinalAnsA(child);

    const dir_size = node.size();
    if (dir_size < 100_000)
        sum += dir_size;

    return sum;
}

pub fn b(input: []const u8) !u32 {
    // init allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var alloc = gpa.allocator();

    // init root node
    var root_node = try alloc.create(DirNode);
    root_node.* = .{
        .name = "/",
        .parent = undefined,
        .allocator = &alloc,
    };
    root_node.parent = root_node;
    defer root_node.deinit();

    // parse input
    var curr_node = root_node;
    var it = std.mem.split(u8, input, "\n");
    while (it.next()) |line|
        try parseLine(line, root_node, &curr_node, &alloc);

    const total_disk_space = 70_000_000;
    const unused_disk_space_target = 30_000_000;
    const used_disk_space = root_node.size();
    const size_to_del = unused_disk_space_target - (total_disk_space - used_disk_space);
    return calcFinalAnsB(root_node, size_to_del);
}

fn calcFinalAnsB(node: *DirNode, size_to_del: u32) u32 {
    var min: u32 = node.size();

    var children_ptrs: []*DirNode = undefined;
    children_ptrs = if (node.children) |children|
        children.values()
    else
        &[_]*DirNode{};
    for (children_ptrs) |child| {
        const child_min = calcFinalAnsB(child, size_to_del);
        if (child_min < min and child_min >= size_to_del)
            min = child_min;
    }

    return min;
}

test "7" {
    const input =
        \\$ cd /
        \\$ ls
        \\dir a
        \\14848514 b.txt
        \\8504156 c.dat
        \\dir d
        \\$ cd a
        \\$ ls
        \\dir e
        \\29116 f
        \\2557 g
        \\62596 h.lst
        \\$ cd e
        \\$ ls
        \\584 i
        \\$ cd ..
        \\$ cd ..
        \\$ cd d
        \\$ ls
        \\4060174 j
        \\8033020 d.log
        \\5626152 d.ext
        \\7214296 k
    ;

    try std.testing.expect(try a(input) == 95437);
    try std.testing.expect(try b(input) == 24933642);
}
