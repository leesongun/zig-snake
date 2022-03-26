const std = @import("std");
const read = std.os.linux.read;
const cursor = @import("cursor.zig").cursor;

//pub const init = ("." ** 8 ++ "\n") ** 7 ++ "." ** 8;
pub const init = ("l" ++ "q" ** 8 ++ "k\n") ++ ("x\t x\n") ** 8 ++ ("m" ++ "q" ** 8 ++ "j");

fn blank() u64 {
    return ~map[0] & ~map[1];
}
fn zero(index: u6) void {
    map[0] &= ~(@as(u64, 1) << index);
    map[1] &= ~(@as(u64, 1) << index);
}
fn set(index: u6, value: u2) void {
    map[0] |= @as(u64, value >> 1) << index;
    map[1] |= @as(u64, value & 1) << index;
}
fn get(index: u6) u2 {
    return (@truncate(u2, map[0] >> index) << 1) |
        @truncate(u1, map[1] >> index);
}
fn newfruit() ?void {
    const bb = blank() ^ head.mask();
    if (bb == 0) return null;
    const r = rand.random()
        .uintLessThanBiased(u6, @intCast(u6, @popCount(u64, bb)));
    fruit = @intCast(u6, @ctz(u64, @import("utils.zig").getbit(bb, r)));
    cursor.mcursor(@truncate(u3, fruit >> 3), @truncate(u3, fruit), '*');
}

//change blank to 2
var map = [2]u64{ 0, 0 };
var fruit: u6 = undefined;
var head: cursor = undefined;
//should actually read /dev/urandom 8bytes
var rand = std.rand.Sfc64.init(1);
pub fn main() void {
    head = .{ .dir = 0, .x = 4, .y = 4 }; //change this later
    var tail = head;
    newfruit() orelse unreachable;

    while (true) {
        head.print("<^>V"[head.dir]);
        std.time.sleep(1_5000_0000);
        var newdir: u2 = head.dir ^ 2;
        while (true) {
            var buff: [1]u8 = undefined;
            const bytes = read(0, &buff, 1);
            if (bytes == 0) break;
            var newnewdir: u2 = switch (buff[0]) {
                'D', 'H', 'h', 'a' => 2,
                'C', 'L', 'l', 'd' => 0,
                'B', 'J', 'j', 's' => 1,
                'A', 'K', 'k', 'w' => 3,
                else => continue,
            };
            if (newnewdir != head.dir)
                newdir = newnewdir;
        }
        const arrows = "xjxk" ++ "qlqm";
        const suffix = (head.dir == 0) or (newdir == 0);
        const t = @as(u3, @boolToInt(suffix)) << 2;
        head.print(arrows[(head.dir ^ newdir) + t]);
        set(head.index(), head.dir ^ newdir);
        head.dir = newdir ^ 2;
        head.move() catch break;

        if (head.index() != fruit) {
            tail.dir ^= 2 ^ get(tail.index());
            zero(tail.index());
            if (head.mask() & blank() == 0) //die
                break;
            //if (tail.index() != head.index())
            tail.print(' ');
            tail.move() catch unreachable;
        } else newfruit() orelse break;
    }
}
