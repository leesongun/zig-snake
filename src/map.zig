const Self = @This();

pub fn blank(self: Self) u64 {
    return ~self._[0] & ~self._[1];
}
pub fn zero(self: *Self, ind: u6) void {
    self._[0] &= ~(@as(u64, 1) << ind);
    self._[1] &= ~(@as(u64, 1) << ind);
}
pub fn set(self: *Self, ind: u6, value: u2) void {
    self._[0] |= @as(u64, value >> 1) << ind;
    self._[1] |= @as(u64, value & 1) << ind;
}
pub fn get(self: Self, ind: u6) u2 {
    return (@truncate(u2, self._[0] >> ind) << 1) |
        @truncate(u1, self._[1] >> ind);
}

//change blank to 2
_: @Vector(2, u64) = .{ 0, 0 },
