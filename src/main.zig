const std = @import("std");
const day = @import("7.zig");

pub fn main() !void {
    const input = @embedFile("../inputs/" ++ @typeName(day) ++ ".txt");

    inline for (@typeInfo(day).Struct.decls) |decl| {
        const first_letter = if (decl.name.len == 1) decl.name[0] else 0;
        switch (first_letter) {
            'a' => try print(try day.a(input)),
            'b' => try print(try day.b(input)),
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
    std.testing.refAllDecls(day);
}
