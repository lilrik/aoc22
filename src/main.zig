const std = @import("std");
const current = @import("6.zig");

pub fn main() !void {
    const input = @embedFile("../inputs/input.txt");

    inline for (@typeInfo(current).Struct.decls) |decl| {
        const first_letter = if (decl.name.len == 1) decl.name[0] else 0;
        switch (first_letter) {
            'a' => try print(try current.a(input)),
            'b' => try print(try current.b(input)),
            else => {},
        }
    }
}

fn print(res: anytype) !void {
    const stdout = std.io.getStdOut().writer();
    switch (@TypeOf(res)) {
        u32 => try stdout.print("{}\n", .{res}),
        []const u8 => try stdout.print("{s}\n", .{res}),
        else => unreachable,
    }
}

test {
    std.testing.refAllDecls(current);
}
