const std = @import("std");
const errc = @import("error.zig");
const bytec = @import("bytecode.zig");

pub const ParseErr = error {
    ErrCompilationfail,
};

pub const BfParser = struct {
    const Self = @This();

    reader: std.io.AnyReader,
    alloc: std.mem.Allocator,

    program: std.ArrayList(bytec.BfBytecodeOp),

    // additional parsing context
    braces_index: std.ArrayList(usize),

    pub fn init(alloc: std.mem.Allocator, reader: std.io.AnyReader) !Self {
        return Self{
            .alloc = alloc,
            .reader = reader,
            .program = std.ArrayList(bytec.BfBytecodeOp).init(alloc),
            .braces_index = std.ArrayList(usize).init(alloc),
        };
    }

    pub fn deinit(self: *Self) void {
        self.program.deinit();
        self.braces_index.deinit();
    }

    fn appendToProgram(self: *Self, slice: []u8) !void {
        for (0..slice.len) |index| {
            var tr_instr = bytec.fromByte(slice[index]) orelse continue;

            switch (tr_instr.raw_op) {
                .JmpO => {
                    try self.braces_index.append(self.program.items.len);
                },

                .JmpC => {
                    const whereat = self.braces_index.popOrNull() orelse {
                        errc.handleErrWithCtx(&.{
                            .window = slice,
                            .offset = index,
                            .message = "closed a jmp without opening it first"
                        });

                        return ParseErr.ErrCompilationfail;
                    };

                    self.program.items[whereat].arg = self.program.items.len;
                    tr_instr.arg = whereat;
                },

                else => {},
            }

            try self.program.append(tr_instr);
        }

        return;
    }

    pub fn tryLex(self: *Self) !void {
        var raw_buf: [16]u8 = undefined;
        while (self.reader.read(&raw_buf)) |read_bytes| {
            if (read_bytes == 0) {
                if (self.braces_index.items.len != 0) {
                    errc.handleErrWithCtx(&.{
                        .message = "you smelly buffoon, you didn't close your jmp",
                    });

                    return ParseErr.ErrCompilationfail;
                }
                return;
            }

            try self.appendToProgram(raw_buf[0..read_bytes]);
        } else |_| {}

        return;
    }
};


