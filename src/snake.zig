const os = @import("std").os.linux;
const cursor = @import("cursor.zig");
const getdir = cursor.getdir;
const xordir = cursor.xordir;
const index = cursor.index;

pub const init = ("l" ++ "q" ** 8 ++ "k\n") ++ ("x\t x\n") ** 8 ++ ("m" ++ "q" ** 8 ++ "j");

fn newfruit() ?void {
    const bb = map.blank() ^ cursor.mask(head);
    fruit.newfruit(bb) orelse return null;
    cursor.print(fruit.pos, '*');
}

//change blank to 2
var map = @import("map.zig"){};
var fruit = @import("fruit.zig").init();
var head = cursor.init(4, 0, 2);
var tail = cursor.init(4, 0, 2);
pub fn main() void {
    newfruit().?;

    while (true) {
        cursor.print(head, "<^>V"[getdir(head)]);

        const temp = os.timespec{ .tv_sec = 0, .tv_nsec = 1_5000_0000 };
        _ = os.nanosleep(&temp, null);

        const newdir = scandir(getdir(head));
        printneck(newdir);

        map.set(index(head), getdir(head) ^ newdir);
        cursor.setdir(&head, newdir ^ 2);
        head = cursor.check_move(head) orelse break;

        if (index(head) != fruit.pos) {
            xordir(&tail, 2 ^ map.get(index(tail)));
            map.zero(index(tail));
            if (cursor.mask(head) & map.blank() == 0) //die
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
