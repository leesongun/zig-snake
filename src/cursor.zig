const std = @import("std");

pub const cursor = packed struct {
    const Self = @This();
    dir: u2,
    x: u3,
    y: u3,
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
    pub fn index(self: Self) u6 {
        return @as(u6, self.x) * 8 + self.y;
    }
    pub fn mask(self: Self) u64 {
        return @as(u64, 1) << self.index();
    }
};
