const std = @import("std");
const read = std.io.getStdIn().read;
const write = std.io.getStdOut().writeAll;

const cursor = @import("cursor.zig").cursor;
const getbit = @import("utils.zig").getbit;
//change blank to 2
var map = [2]u64{ 0, 0 };

var fruit: u6 = 0;
var head: cursor = undefined;
var tail: cursor = undefined;

fn blank() u64 {
    return ~map[0] & ~map[1];
}
fn reset(index: u6) void {
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
fn newfruit() ?u6 {
    const bb = blank() ^ head.mask();
    if (bb == 0) return null;
    const r = rand.random()
        .uintLessThanBiased(u6, @intCast(u6, @popCount(u64, bb)));
    return @intCast(u6, @ctz(u64, getbit(bb, r)));
}

var rand = std.rand.DefaultPrng.init(1);
pub fn main_loop() anyerror!void {
    head = .{ .dir = 0, .x = 4, .y = 4 }; //change this later
    tail = head;
    fruit = newfruit() orelse unreachable;
    set(head.index(), 2);

    while (true) {
        try render();
        std.time.sleep(3_0000_0000);
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

        set(head.index(), head.dir ^ newdir ^ 2);
        head.dir = newdir;
        head.move() catch break;
        if (head.mask() & blank() == 0) //die
            break;
        if (head.index() == fruit) {
            fruit = newfruit() orelse break;
        } else {
            tail.dir ^= 2 ^ get(tail.index());
            reset(tail.index());
            tail.move() catch unreachable;
        }
    }
    //print score
}

fn render() !void {
    //should this be a global variable?
    var out = ("\x1B[1;1H" ++ ("o" ** 8 ++ "\n") ** 8).*;

    var c: u64 = blank();
    while (c != 0) : (c &= c - 1) {
        const i = @ctz(u64, c);
        out[i + "\x1B[1;1H".len + (i >> 3)] = '.';
    }
    {
        const i = fruit;
        out[i + "\x1B[1;1H".len + (i >> 3)] = '*';
    }
    {
        const i = head.index();
        out[i + "\x1B[1;1H".len + (i >> 3)] = 'O';
    }
    try write(&out);
}
