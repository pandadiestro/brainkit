const std = @import("std");
const instr = @import("instr.zig");

pub const BfBytecodeOp = struct {
    arg: ?usize = null,
    raw_op: instr.BfInstrEnum,
};

pub fn fromByte(byte: u8) ?BfBytecodeOp {
    const raw_instr = instr.translateByte(byte);
    switch (raw_instr) {
        .Comment, .Whitespace => return null,
        else => return BfBytecodeOp{
            .raw_op = raw_instr,
        },
    }
}

