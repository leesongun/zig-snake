const std = @import("std");

const os = std.os.linux;
const handle = std.io.getStdIn().handle;
const snake = @import("snake.zig");

pub inline fn main() void {
    //hide cursor, clear screen, change chaeset, move cursor
    const init = "\x1B[?25l\x1B[2J\x1B(0\x1B[1;1H" ++ snake.init;
    _ = os.write(1, init, init.len);
    //move cursor, show cursor, change charset
    const deinit = "\x1B[11;1H\x1B[?25h\x1B(B";
    defer _ = os.write(1, deinit, deinit.len);

    const original_termios = rawmode();
    defer _ = os.tcsetattr(handle, .FLUSH, &original_termios);

    snake.main();
}

pub fn rawmode() os.termios {
    var termios: os.termios = undefined;
    _ = os.tcgetattr(handle, &termios);
    var original_termios = termios;

    // man 3 termios
    termios.iflag &= ~@as(os.tcflag_t, os.IGNBRK | os.BRKINT | os.PARMRK | os.ISTRIP | os.INLCR | os.IGNCR | os.ICRNL | os.IXON);
    termios.lflag &= ~@as(os.tcflag_t, os.ECHO | os.ECHONL | os.ICANON | os.ISIG | os.IEXTEN);
    termios.oflag &= ~@as(os.tcflag_t, os.OPOST);
    termios.cflag &= ~@as(os.tcflag_t, os.CSIZE | os.PARENB);
    termios.cflag |= os.CS8;

    termios.cc[6] = 0; // VMIN
    termios.cc[5] = 0; // VTIME

    _ = os.tcsetattr(handle, .FLUSH, &termios);
    return original_termios;
}

test {
    std.testing.refAllDecls(@This());
}
