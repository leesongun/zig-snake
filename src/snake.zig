const std = @import("std");
const os = std.os.linux;
const cursor = @import("cursor.zig");
const getdir = cursor.getdir;
const xordir = cursor.xordir;
const index = cursor.index;

//pub const init = ("." ** 8 ++ "\n") ** 7 ++ "." ** 8;
pub const init = ("l" ++ "q" ** 8 ++ "k\n") ++ ("x\t x\n") ** 8 ++ ("m" ++ "q" ** 8 ++ "j");

fn blank() u64 {
    return ~map[0] & ~map[1];
}
fn zero(ind: u6) void {
    map[0] &= ~(@as(u64, 1) << ind);
    map[1] &= ~(@as(u64, 1) << ind);
}
fn set(ind: u6, value: u2) void {
    map[0] |= @as(u64, value >> 1) << ind;
    map[1] |= @as(u64, value & 1) << ind;
}
fn get(ind: u6) u2 {
    return (@truncate(u2, map[0] >> ind) << 1) |
        @truncate(u1, map[1] >> ind);
}
fn newfruit() ?void {
    const bb = blank() ^ cursor.mask(head);
    if (bb == 0) return null;
    const r = rand.random()
        .uintLessThanBiased(u6, @intCast(u6, @popCount(u64, bb)));
    fruit = @intCast(u6, @ctz(u64, @import("utils.zig").getbit(bb, r)));
    cursor.print(fruit, '*');
}

//change blank to 2
var map = [2]u64{ 0, 0 };
var fruit: u6 = undefined;
var head = cursor.init(4, 0, 2);
var tail = cursor.init(4, 0, 2);
//should actually read /dev/urandom 8bytes
var rand = std.rand.Sfc64.init(1);
pub fn main() void {
    newfruit() orelse unreachable;

    while (true) {
        cursor.print(head, "<^>V"[getdir(head)]);

        const temp = os.timespec{ .tv_sec = 0, .tv_nsec = 1_5000_0000 };
        _ = os.nanosleep(&temp, null);

        const newdir = scandir(getdir(head));
        printneck(newdir);

        set(index(head), getdir(head) ^ newdir);
        cursor.setdir(&head, newdir ^ 2);
        head = cursor.check_move(head) orelse break;

        if (index(head) != fruit) {
            xordir(&tail, 2 ^ get(index(tail)));
            zero(index(tail));
            if (cursor.mask(head) & blank() == 0) //die
                break;
            //if (tail.index() != index(head))
            cursor.print(tail, ' ');
            //tail.move() catch unreachable;
            tail = cursor.move(tail);
        } else newfruit() orelse break;
    }
}

fn scandir(curdir: u2) u2 {
    while (true) {
        var buff: [1]u8 = undefined;
        if (os.read(0, &buff, 1) == 0)
            return curdir ^ 2;
        var newdir: u2 = switch (buff[0]) {
            'D' => 2, // 'D', 'H', 'h', 'a' => 2,
            'C' => 0, // 'C', 'L', 'l', 'd' => 0,
            'B' => 1, // 'B', 'J', 'j', 's' => 1,
            'A' => 3, // 'A', 'K', 'k', 'w' => 3,
            else => continue,
        };
        if (newdir != curdir)
            return newdir;
    }
}

fn printneck(newdir: u2) void {
    const arrows = "xjxk" ++ "qlqm";
    const suffix = (getdir(head) == 0) or (newdir == 0);
    const t = @as(u3, @boolToInt(suffix)) << 2;
    cursor.print(head, arrows[(getdir(head) ^ newdir) + t]);
}
