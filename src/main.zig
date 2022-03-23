const std = @import("std");

const os = std.os.linux;
const handle = std.io.getStdIn().handle;
const write = std.io.getStdOut().writeAll;

pub fn main() anyerror!void {
    const original_termios = rawmode();
    defer _ = os.tcsetattr(handle, .FLUSH, &original_termios);

    try write("\x1B[?25l\x1B[2J"); //hide cursor, clear screen
    defer write("\x1B[?25h") catch {}; //show cursor

    return @import("snake.zig").main();
}

// rawmode with OPOST
pub fn rawmode() os.termios {
    var termios: os.termios = undefined;
    _ = os.tcgetattr(handle, &termios);
    var original_termios = termios;

    // man 3 termios
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

    termios.cc[6] = 0; // VMIN
    termios.cc[5] = 0; // VTIME

    _ = os.tcsetattr(handle, .FLUSH, &termios);
    return original_termios;
}
