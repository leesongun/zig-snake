const os = @import("std").os.linux;
pub const init = ("l" ++ "q" ** 8 ++ "k\n") ++ ("x\t x\n") ** 8 ++ ("m" ++ "q" ** 8 ++ "j");

pub fn seed() u64 {
    var ret: u64 = undefined;
    const fd = @intCast(i32, os.open("/dev/urandom", os.O.RDONLY, undefined));
    _ = os.read(fd, @ptrCast([*]u8, &ret), 8);
    _ = os.close(fd);
    return ret;
}

pub fn scandir(curdir: u2) u2 {
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

pub var printer = "\x1B[0;0H.".*;
pub fn print(pos: u6, char: u8) void {
    printer["\x1B[".len] = @as(u8, '2') + (pos >> 3);
    printer["\x1B[0;".len] = @as(u8, '2') + (pos & 7);
    printer[printer.len - 1] = char;
    _ = os.write(1, &printer, printer.len);
}

const wait = os.timespec{ .tv_sec = 0, .tv_nsec = 1_5000_0000 };
pub fn sleep() void {
    _ = os.nanosleep(&wait, null);
}

const printtype = enum {
    tail,
    neck,
    head,
    fruit,
};
