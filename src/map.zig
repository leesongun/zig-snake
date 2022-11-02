const Self = @This();

pub fn blank(self: Self) u64 {
    return ~@reduce(.Or, self._);
}
pub fn zero(self: *Self, ind: u6) void {
    self._ &= @splat(2, ~(@as(u64, 1) << ind));
}
pub fn set(self: *Self, ind: u6, value: u2) void {
    const _m = @bitCast(@Vector(2, u1), value);
    self._ |= @as(@Vector(2, u64), _m) << @splat(2, ind);
}
pub fn get(self: Self, ind: u6) u2 {
    const x = (self._ >> @splat(2, ind) & @splat(2, @as(u64, 1))) << .{ 0, 1 };
    return @intCast(u2, @reduce(.Or, x));
}

//change blank to 2
_: @Vector(2, u64) = .{ 0, 0 },
