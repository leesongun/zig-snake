const std = @import("std");

const os = std.os.linux;
const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut();

const cursor = packed struct {
    const Self = @This();
    dir: u2,
    x: u3,
    y: u3,
    pub fn move(self: *Self) !void {
        const add = std.math.add;
        const sub = std.math.sub;
        switch (self.dir) {
            0 => self.y = try sub(u3, self.y, 1),
            1 => self.x = try add(u3, self.x, 1),
            2 => self.y = try add(u3, self.y, 1),
            3 => self.x = try sub(u3, self.x, 1),
        }
    }
    pub fn index(self: Self) u6 {
        return @as(u6, self.x) * 8 + self.y;
    }
    pub fn mask(self: Self) u64 {
        return @as(u64, 1) << self.index();
    }
};

const getbit = @import("utils.zig").getbit;
//change blank to 2
var map = [2]u64{ 0, 0 };

var fruit: u6 = 0;
var head: cursor = undefined;
var tail: cursor = undefined;

inline fn blank() u64 {
    return ~map[0] & ~map[1];
}

fn erase(ind: u6) void {
    map[0] &= ~(@as(u64, 1) << ind);
    map[1] &= ~(@as(u64, 1) << ind);
}
fn write(ind: u6, value: u2) void {
    map[0] |= @as(u64, value >> 1) << ind;
    map[1] |= @as(u64, value & 1) << ind;
}
fn read(ind: u6) u2 {
    return (@truncate(u2, map[0] >> ind) << 1) | @truncate(u1, map[1] >> ind);
}

pub fn main() anyerror!void {
    const original_termios = rawmode();
    defer _ = os.tcsetattr(stdin.handle, .FLUSH, &original_termios);

    try stdout.writeAll("\x1B[?25l\x1B[2J"); //hide cursor, clear screen
    defer stdout.writeAll("\x1B[?25h") catch {}; //show cursor

    head = .{ .dir = 0, .x = 4, .y = 4 }; //change this later
    tail = head;
    write(head.index(), 2);

    while (true) {
        try render();
        std.time.sleep(3_0000_0000);
        var newdir: u2 = head.dir;
        while (true) {
            var buff: [1]u8 = undefined;
            const bytes = try stdin.read(&buff);
            if (bytes == 0) break;
            var newnewdir: u2 = switch (buff[0]) {
                'q' => return,
                'D', 'H', 'h', 'a' => 0,
                'C', 'L', 'l', 'd' => 2,
                'B', 'J', 'j', 's' => 1,
                'A', 'K', 'k', 'w' => 3,
                else => continue,
            };
            if (newnewdir ^ head.dir != 2)
                newdir = newnewdir;
        }

        write(head.index(), head.dir ^ newdir ^ 2);
        head.dir = newdir;
        head.move() catch break;
        if (head.mask() & blank() == 0) //die
            break;
        if (head.index() == fruit) {
            const rand: u6 = 0;
            const bb = blank() ^ head.mask();
            if (bb == 0) break;
            fruit = @intCast(u6, @ctz(u64, getbit(bb, rand)));
        } else {
            tail.dir ^= 2 ^ read(tail.index());
            erase(tail.index());
            tail.move() catch unreachable;
        }
    }
    //output score
}

//rawmode but with OPOST
fn rawmode() os.termios {
    var termios: os.termios = undefined;
    _ = os.tcgetattr(stdin.handle, &termios);
    var original_termios = termios;

    //man 3 termios
    termios.iflag &= ~@as(
        os.tcflag_t,
        os.IGNBRK | os.BRKINT | os.PARMRK | os.ISTRIP |
            os.INLCR | os.IGNCR | os.ICRNL | os.IXON,
    );
    termios.lflag &= ~@as(
        os.tcflag_t,
        os.ECHO | os.ECHONL | os.ICANON | os.ISIG | os.IEXTEN,
    );
    termios.cflag &= ~@as(os.tcflag_t, os.CSIZE | os.PARENB);
    termios.cflag |= os.CS8;

    termios.cc[6] = 0; //VMIN
    termios.cc[5] = 0; //VTIME

    _ = os.tcsetattr(stdin.handle, .FLUSH, &termios);
    return original_termios;
}

//const bytes = ".oO*";

fn render() !void {
    //should make this global variable?
    var out = ("\x1B[1;1H" ++ ("o" ** 8 ++ "\n") ** 8).*;

    var c: u64 = blank();
    while (c != 0) : (c &= c - 1) {
        const i = @ctz(u64, c);
        out[i + "\x1B[1;1H".len + (i >> 3)] = '.';
    }
    //change head and fruit here
    {
        const i = fruit;
        out[i + "\x1B[1;1H".len + (i >> 3)] = '*';
    }
    {
        const i = head.index();
        out[i + "\x1B[1;1H".len + (i >> 3)] = 'O';
    }
    
    // {
    //     const i = tail.index();
    //     out[i + "\x1B[1;1H".len + (i >> 3)] = '&';
    // }
    try stdout.writeAll(&out);
}
