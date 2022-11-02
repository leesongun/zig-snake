const write = @import("std").os.linux.write;

pub var printer = "\x1B[0;0H.".*;
pub fn move(c: u8) u8 {
    return switch (c >> 6) {
        0 => c - 1,
        1 => c - 8,
        2 => c + 1,
        3 => c + 8,
        else => unreachable,
    };
}
pub fn check_move(c: u8) ?u8 {
    const r = move(c);
    if (@popCount(r ^ c) > 3) return null;
    return r;
}
pub fn index(c: u8) u6 {
    return @truncate(u6, c);
}
pub fn mask(c: u8) u64 {
    return @as(u64, 1) << @truncate(u6, c);
}
pub fn getdir(c: u8) u2 {
    return @truncate(u2, c >> 6);
}
pub fn xordir(c: *u8, d: u2) void {
    c.* ^= @as(u8, d) << 6;
}
pub fn setdir(c: *u8, d: u2) void {
    c.* &= 0o77;
    c.* |= @as(u8, d) << 6;
}
pub fn print(c: u8, char: u8) void {
    printer["\x1B[".len] = @as(u8, '2') + @truncate(u3, c >> 3);
    printer["\x1B[0;".len] = @as(u8, '2') + @truncate(u3, c);
    printer[printer.len - 1] = char;
    _ = write(1, &printer, printer.len);
}
pub fn init(x: u3, y: u3, dir: u2) u8 {
    return (@as(u8, dir) << 6) + (@as(u8, x) << 3) + y;
}
