const std = @import("std");

pub fn a(input: []const u8) !u32 {
    var sum: u32 = 0;

    var it = std.mem.split(u8, input, "\n");
    while (it.next()) |line| {
        const firstLetter = line[0];
        const lastLetter = line[line.len - 1];
        const asciiOffset = 87;

        sum += if (std.mem.eql(u8, line, "A Y") or std.mem.eql(u8, line, "B Z") or std.mem.eql(u8, line, "C X"))
            6
        else if (lastLetter - firstLetter == 23) // draw
            3
        else
            0;
        sum += lastLetter - asciiOffset;
    }

    return sum;
}

pub fn b(input: []const u8) !u32 {
    var sum: u32 = 0;

    var it = std.mem.split(u8, input, "\n");
    while (it.next()) |line| {
        const firstLetter = line[0];
        const lastLetter = line[line.len - 1];
        const asciiOffset = 64;

        sum += switch (lastLetter) {
            'X' => 0 + if (firstLetter == 'A') firstLetter + 2 - asciiOffset else firstLetter - 1 - asciiOffset,
            'Y' => 3 + firstLetter - asciiOffset,
            'Z' => 6 + if (firstLetter == 'C') firstLetter - 2 - asciiOffset else firstLetter + 1 - asciiOffset,
            else => 0,
        };
    }

    return sum;
}

test "2" {
    const input =
        \\A Y
        \\B X
        \\C Z
    ;

    try std.testing.expect(try a(input) == 15);
    try std.testing.expect(try b(input) == 12);
}
