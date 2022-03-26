const std = @import("std");
const os = std.os.linux;

pub const cursor = packed struct {
    const Self = @This();
    pub var printer = "\x1B[0;0H.".*;
    y: u3,
    x: u3,
    dir: u2,
    pub fn move(self: *Self) !void {
        const add = std.math.add;
        const sub = std.math.sub;
        switch (self.dir) {
            0 => self.y = try sub(u3, self.y, 1),
            1 => self.x = try sub(u3, self.x, 1),
            2 => self.y = try add(u3, self.y, 1),
            3 => self.x = try add(u3, self.x, 1),
        }
    }
    pub fn move2(self: *Self) void {
        const a = @ptrCast(*u8, self);
        switch (a.* >> 6) {
            0 => a.* -= 1,
            1 => a.* -= 8,
            2 => a.* += 1,
            3 => a.* += 8,
            else => unreachable,
        }
    }
    pub fn move3(self: *Self) ?void {
        const b = @bitCast(u8, self.*);
        var a = b;
        switch (a >> 6) {
            0 => a -= 1,
            1 => a -= 8,
            2 => a += 1,
            3 => a += 8,
            else => unreachable,
        }
        if (@popCount(u8, a ^ b) > 3) return null;
        self.* = @bitCast(Self, a);
    }
    pub fn index(self: Self) u6 {
        return @as(u6, self.x) * 8 + self.y;
    }
    pub fn mask(self: Self) u64 {
        return @as(u64, 1) << self.index();
    }
    pub fn print(self: Self, char: u8) void {
        mcursor(self.x, self.y, char);
    }
    pub fn mcursor(x: u8, y: u8, char: u8) void {
        printer["\x1B[".len] = '2' + x;
        printer["\x1B[0;".len] = '2' + y;
        printer[printer.len - 1] = char;
        _ = os.write(1, &printer, printer.len);
    }
};

test {
    try std.testing.expectEqual(@bitCast(u8, cursor{ .y = 7, .x = 4, .dir = 2 }), 0o247);
}
