// https://github.com/ziglang/zig/issues/2291
// https://github.com/ziglang/zig/issues/1717
extern fn @"llvm.x86.bmi.pdep.64"(u64, u64) u64;
const Rand = @import("std").rand.Sfc64;

fn getbit(bits: u64, rank: u6) u64 {
    return @"llvm.x86.bmi.pdep.64"(@as(u64, 1) << rank, bits);
}
const Self = @This();
pos: u6,
rand: Rand = Rand.init(1),
pub fn init() Self {
    //should read from /dev/urandom
    //try std.fs.cwd().openFile("foo.txt", .{});
    //defer file.close();
    //
    //var buf_reader = std.io.bufferedReader(file.reader());
    //var in_stream = buf_reader.reader();
    //
    //var buf: [1024]u8 = undefined;
    //while (try in_stream.readUntilDelimiterOrEof
    return .{
        .rand = Rand.init(1),
        .pos = undefined,
    };
}
pub fn newfruit(self: *Self, bb: u64) ?void {
    if (bb == 0) return null;
    const r = self.rand.random()
        .uintLessThanBiased(u6, @intCast(u6, @popCount(bb)));
    self.pos = @intCast(u6, @ctz(@import("utils.zig").getbit(bb, r)));
}
