// https://github.com/ziglang/zig/issues/2291
// https://github.com/ziglang/zig/issues/1717
extern fn @"llvm.x86.bmi.pdep.64"(u64, u64) u64;

inline fn pdep(a: u64, b: u64) u64 {
    return @"llvm.x86.bmi.pdep.64"(a, b);
}

pub fn getbit(bits: u64, rank: u6) u64 {
    return pdep(@as(u64, 1) << rank, bits);
}
