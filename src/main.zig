const std = @import("std");
const current = @import("3.zig");

pub fn main() !void {
    const input = @embedFile("../inputs/input.txt");
    var res: ?u32 = null;

    const stdout = std.io.getStdOut().writer();
    inline for (@typeInfo(current).Struct.decls) |decl| {
        const first_letter = if (decl.name.len == 1) decl.name[0] else 0;
        switch (first_letter) {
            'a' => res = try current.a(input),
            'b' => res = try current.b(input),
            else => res = null,
        }
        if (res) |r| try stdout.print("{d}\n", .{r});
    }
}

test {
    std.testing.refAllDecls(current);
}
