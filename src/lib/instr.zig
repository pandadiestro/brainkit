const std = @import("std");

pub const BfInstrErr = error {
    ErrInvalidOp,
};

pub const BfInstrEnum = enum(u8) {
    Add     = '+',
    Red     = '-',
    MovR    = '>',
    MovL    = '<',
    Out     = '.',
    Rep     = ',',
    JmpO    = '[',
    JmpC    = ']',
    Whitespace,
    Comment,
};

pub fn translateByte(byte: u8) BfInstrEnum {
    return switch (byte) {
        '+', '-', '>', '<', '.', ',', '[', ']' => @enumFromInt(byte),
        ' ', '\r', '\n', '	' => BfInstrEnum.Whitespace,
        else => BfInstrEnum.Comment
    };
}

