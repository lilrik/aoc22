const std = @import("std");

pub fn a(in_stream: anytype) !u32 {
    var buf: [4]u8 = undefined;
    var sum: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const firstLetter = line[0];
        const lastLetter = line[line.len-1];
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

pub fn b(in_stream: anytype) !u32 {
    var buf: [4]u8 = undefined;
    var sum: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const firstLetter = line[0];
        const lastLetter = line[line.len-1];
        const asciiOffset = 64;

        sum += if (lastLetter == 'X')
            0 + if (firstLetter == 65) firstLetter + 2 - asciiOffset else firstLetter - 1 - asciiOffset
        else if (lastLetter == 'Y')
            3 + firstLetter - asciiOffset
        else if (lastLetter == 'Z')
            6 + if (firstLetter == 67) firstLetter - 2 - asciiOffset else firstLetter + 1 - asciiOffset
        else
            0;
    }
    return sum;
}

test "2" {
    const in =
        \\A Y
        \\B X
        \\C Z
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

    try std.testing.expect(try a(in_stream) == 15);
    try file.seekTo(0);
    try std.testing.expect(try b(in_stream) == 12);
}
