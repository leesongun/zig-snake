// https://github.com/ziglang/zig/issues/2291
// https://github.com/ziglang/zig/issues/1717
extern fn @"llvm.x86.bmi.pdep.64"(u64, u64) u64;

const Self = @This();
const Rand = @import("std").rand.Sfc64;

pos: u6,
rand: Rand,

pub fn seed(self: *Self, s: u64) void {
    self.rand = Rand.init(s);
}

pub fn newfruit(self: *Self, bb: u64) ?void {
    if (bb == 0) return null;
    const r = self.rand.random()
        .uintLessThanBiased(u6, @intCast(u6, @popCount(bb)));
    self.pos = @intCast(u6, @ctz(@"llvm.x86.bmi.pdep.64"(@as(u64, 1) << r, bb)));
}
