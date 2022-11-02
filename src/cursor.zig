pub usingnamespace packed struct(u8) {
    pos: u6 = 0o40,
    dir: u2 = 2,
    pub const Self = @This();
    fn to(self: Self) u8 {
        return @bitCast(u8, self);
    }
    pub fn move(self: *Self) ?void {
        const r = self.*;
        @ptrCast(*i8, self).* += switch (self.dir) {
            0 => -1,
            1 => -8,
            2 => 1,
            3 => 8,
        };
        if (@popCount(r.to() ^ self.to()) > 3) return null;
    }
    pub fn mask(self: Self) u64 {
        return @as(u64, 1) << self.pos;
    }
    pub fn init(c: u6) Self {
        return .{ .pos = c };
    }
};
