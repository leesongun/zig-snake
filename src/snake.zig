const io = @import("io.zig");
const cursor = @import("cursor.zig");
pub const init = io.init;

fn newfruit() ?void {
    const bb = map.blank() ^ cursor.mask(head);
    fruit.newfruit(bb) orelse return null;
    io.print(fruit.pos, '*');
}

var map = @import("map.zig"){};
var fruit : @import("fruit.zig") = undefined;
var head = cursor.init(0o40);
var tail = cursor.init(0o40);
pub fn main() void {
    fruit.seed(io.seed());
    newfruit().?;

    while (true) {
        io.print(head.pos, "<^>V"[head.dir]);

        io.sleep();
        const newdir = io.scandir(head.dir);
        printneck(newdir);
        map.store(head, newdir);
        head.dir = newdir ^ 2;
        head.move() orelse break;

        if (head.pos != fruit.pos) {
            map.load(&tail);
            map.zero(tail);
            if (head.mask() & map.blank() == 0) //die
                break;
            //if (tail.index() != index(head))
            io.print(tail.pos, ' ');
            tail.move() orelse unreachable;
        } else newfruit() orelse break;
    }
}

fn printneck(newdir: u2) void {
    const arrows = " lqml kxqk jmxj";
    io.print(head.pos, arrows[4 * @as(u4, newdir) + head.dir]);
}
