const Self = @This();
const Cur = @import("cursor.zig").Self;

pub fn blank(self: Self) u64 {
    return ~@reduce(.Or, self._);
}
pub fn zero(self: *Self, c: Cur) void {
    self._ &= @splat(2, ~c.mask());
}
pub fn store(self: *Self, c: Cur, dir: u2) void {
    const _m = @bitCast(@Vector(2, u1), dir ^ c.dir);
    self._ |= @as(@Vector(2, u64), _m) << @splat(2, c.pos);
}
pub fn load(self: Self, c: *Cur) void {
    const x = (self._ >> @splat(2, c.pos) & @splat(2, @as(u64, 1))) << .{ 0, 1 };
    c.dir ^= 2 ^ @intCast(u2, @reduce(.Or, x));
}

//change blank to 2
_: @Vector(2, u64) = .{ 0, 0 },
