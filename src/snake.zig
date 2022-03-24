const std = @import("std");
const read = std.io.getStdIn().read;
const cursor = @import("cursor.zig").cursor;

pub const init = "\x1B[1;1H" ++ ("." ** 8 ++ "\n") ** 8;

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
fn newfruit() !?void {
    const bb = blank() ^ head.mask();
    if (bb == 0) return null;
    const r = rand.random()
        .uintLessThanBiased(u6, @intCast(u6, @popCount(u64, bb)));
    fruit = @intCast(u6, @ctz(u64, @import("utils.zig").getbit(bb, r)));
    try cursor.mcursor(@truncate(u3, fruit >> 3), @truncate(u3, fruit), '*');
}

//change blank to 2
var map = [2]u64{ 0, 0 };
var fruit: u6 = 0;
var head: cursor = undefined;
//should actually read /dev/urandom 8bytes
var rand = std.rand.DefaultPrng.init(1);
pub fn main() !void {
    head = .{ .dir = 0, .x = 4, .y = 4 }; //change this later
    var tail = head;
    (try newfruit()) orelse unreachable;
    set(head.index(), 2);

    while (true) {
        try head.print("<^>v"[head.dir]);
        std.time.sleep(2_0000_0000);
        var newdir: u2 = head.dir;
        while (true) {
            var buff: [1]u8 = undefined;
            const bytes = try read(&buff);
            if (bytes == 0) break;
            var newnewdir: u2 = switch (buff[0]) {
                'q' => return,
                'D', 'H', 'h', 'a' => 0,
                'C', 'L', 'l', 'd' => 2,
                'B', 'J', 'j', 's' => 3,
                'A', 'K', 'k', 'w' => 1,
                else => continue,
            };
            if (newnewdir ^ head.dir != 2)
                newdir = newnewdir;
        }

        try head.print('o');
        set(head.index(), head.dir ^ newdir ^ 2);
        head.dir = newdir;
        head.move() catch break;

        if (head.index() != fruit) {
            tail.dir ^= 2 ^ get(tail.index());
            zero(tail.index());
            if (head.mask() & blank() == 0) //die
                break;
            //if (tail.index() != head.index())
            try tail.print('.');
            tail.move() catch unreachable;
        } else (try newfruit()) orelse break;
    }
    //print score
}
