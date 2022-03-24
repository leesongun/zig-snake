const std = @import("std");

const os = std.os.linux;
const handle = std.io.getStdIn().handle;
const snake = @import("snake.zig");

pub inline fn main() void {
    const original_termios = rawmode();
    defer _ = os.tcsetattr(handle, .FLUSH, &original_termios);

    const init = "\x1B[?25l\x1B[2J" ++ snake.init;
    _ = os.write(1, init, init.*.len); //hide cursor, clear screen
    defer _ = os.write(1, "\x1B[9;1H\x1B[?25h", "\x1B[9;1H\x1B[?25h".len); //move cursor, show cursor

    snake.main();
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
