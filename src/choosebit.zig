//use segment tree to scale
pub fn getbit(bits: u64, rank: u6) u6 {
    var res: u6 = 0;
    comptime var i: u6 = 32;
    inline while (i != 0) : (i >>= 1) {
        const mask = (@as(u64, 1) << (res + i)) - 1;
        if (rank >= @popCount(u64, mask & bits))
            res += i;
    }
    return res;
}

//https://graphics.stanford.edu/~seander/bithacks.html#SelectPosFromMSBRank
fn rand_nopopcnt(bitmap: u64, rank: u6) u6 {
    var v = bitmap;
    var r = @as(u7, rank) + 1;
    var s: u8 = undefined;

    const ones = ~@as(u64, 0);
    //unsigned int t;      // Bit count temporary.

    // Do a normal parallel bit count for a 64-bit integer,
    // but store all intermediate steps.
    // a = (v & 0x5555...) + ((v >> 1) & 0x5555...);
    const a = v - ((v >> 1) & ones / 3);
    // b = (a & 0x3333...) + ((a >> 2) & 0x3333...);
    const b = (a & ones / 5) + ((a >> 2) & ones / 5);
    // c = (b & 0x0f0f...) + ((b >> 4) & 0x0f0f...);
    const c = (b + (b >> 4)) & ones / 0x11;
    // d = (c & 0x00ff...) + ((c >> 8) & 0x00ff...);
    const d = (c + (c >> 8)) & ones / 0x101;
    var t = @intCast(u16, (d >> 32) + (d >> 48));
    // Now do branchless select!
    s = 64;
    // if (r > t) {s -= 32; r -= t;}
    s -= ((t - r) & 256) >> 3;
    r -= (t & ((t - r) >> 8));
    t = (d >> (s - 16)) & 0xff;
    // if (r > t) {s -= 16; r -= t;}
    s -= ((t - r) & 256) >> 4;
    r -= (t & ((t - r) >> 8));
    t = (c >> (s - 8)) & 0xf;
    // if (r > t) {s -= 8; r -= t;}
    s -= ((t - r) & 256) >> 5;
    r -= (t & ((t - r) >> 8));
    t = (b >> (s - 4)) & 0x7;
    // if (r > t) {s -= 4; r -= t;}
    s -= ((t - r) & 256) >> 6;
    r -= (t & ((t - r) >> 8));
    t = (a >> (s - 2)) & 0x3;
    // if (r > t) {s -= 2; r -= t;}
    s -= ((t - r) & 256) >> 7;
    r -= (t & ((t - r) >> 8));
    t = (v >> (s - 1)) & 0x1;
    // if (r > t) s--;
    s -= ((t - r) & 256) >> 8;
    return @intCast(u6, 64 - s);
}
fn partial_popcnts(bitmap: u64) [5]u64 {
    unreachable;
}

fn rand_nopopcnt2(bitmap: u64, rank: u6) u6 {
    var r = rank;
    var s: u6 = 0;
    var t: u6 = undefined;

    const popcounts = init: {
        const ones = ~@as(u64, 0);
        const v = bitmap;
        // a = (v & 0x5555...) + ((v >> 1) & 0x5555...);
        const a = v - ((v >> 1) & ones / 3);
        // b = (a & 0x3333...) + ((a >> 2) & 0x3333...);
        const b = (a & ones / 5) + ((a >> 2) & ones / 5);
        // c = (b & 0x0f0f...) + ((b >> 4) & 0x0f0f...);
        const c = (b + (b >> 4)) & ones / 0x11;
        // d = (c & 0x00ff...) + ((c >> 8) & 0x00ff...);
        const d = (c + (c >> 8)) & ones / 0x101;
        t = @truncate(u6, (d >> 8) + d);
        break :init [_]u64{ v, a, b, c, d };
    };
    //0x1F sufficies, but 0xFF might be faster
    const masks = [_]u64{ 0x1, 0x3, 0x7, 0xF, 0xFF };

    comptime var i = 5;
    inline while (i > 0) : (i -= 1) {
        if (r >= t) {
            s += (1 << i);
            r -= t;
        }
        t = @intCast(u6, (popcounts[i - 1] >> s) & masks[i - 1]);
    }
    if (r >= t)
        s += 1;
    return s;
}
