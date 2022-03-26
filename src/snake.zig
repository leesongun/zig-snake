const std = @import("std");
const os = std.os.linux;
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
var head: cursor = .{ .dir = 2, .x = 4, .y = 0 }; //change this later
var tail: cursor = .{ .dir = 2, .x = 4, .y = 0 };
//should actually read /dev/urandom 8bytes
var rand = std.rand.Sfc64.init(1);
pub fn main() void {
    newfruit() orelse unreachable;

    while (true) {
        head.print("<^>V"[head.dir]);

        const temp = os.timespec{ .tv_sec = 0, .tv_nsec = 1_5000_0000 };
        _ = os.nanosleep(&temp, null);

        const newdir = scandir();
        printneck(newdir);

        set(head.index(), head.dir ^ newdir);
        head.dir = newdir ^ 2;
        head.move3() orelse break;

        if (head.index() != fruit) {
            tail.dir ^= 2 ^ get(tail.index());
            zero(tail.index());
            if (head.mask() & blank() == 0) //die
                break;
            //if (tail.index() != head.index())
            tail.print(' ');
            //tail.move() catch unreachable;
            tail.move2();
        } else newfruit() orelse break;
    }
}

fn scandir() u2 {
    while (true) {
        var buff: [1]u8 = undefined;
        if (os.read(0, &buff, 1) == 0)
            return head.dir ^ 2;
        var newnewdir: u2 = switch (buff[0]) {
            'D' => 2, // 'D', 'H', 'h', 'a' => 2,
            'C' => 0, // 'C', 'L', 'l', 'd' => 0,
            'B' => 1, // 'B', 'J', 'j', 's' => 1,
            'A' => 3, // 'A', 'K', 'k', 'w' => 3,
            else => continue,
        };
        if (newnewdir != head.dir)
            return newnewdir;
    }
}

fn printneck(newdir: u2) void {
    const arrows = "xjxk" ++ "qlqm";
    const suffix = (head.dir == 0) or (newdir == 0);
    const t = @as(u3, @boolToInt(suffix)) << 2;
    head.print(arrows[(head.dir ^ newdir) + t]);
}
