const std = @import("std");
const bytec = @import("bytecode.zig");
const instr = @import("instr.zig");

pub fn Memory(blocksize: comptime_int) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        blocks: usize = 1,

        offset: usize = 0,
        band: []u8,

        pub fn init(alloc: std.mem.Allocator) !Self {
            const new = Self{
                .allocator = alloc,
                .band = try alloc.alloc(u8, blocksize),
            };

            @memset(new.band, 0);
            return new;
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.band);
        }

        fn regrow(self: *Self) !void {
            const cycles = self.offset % blocksize;
            self.blocks += cycles;

            const newsize = (self.blocks) * blocksize;
            self.band = try self.allocator.realloc(self.band, newsize);
        }

        pub fn fetch(self: *Self) !u8 {
            if (self.offset >= blocksize) {
                try self.regrow();
                self.band[self.offset] = 0;
            }

            return self.band[self.offset];
        }

        pub fn post(self: *Self, data: u8) !void {
            if (self.offset >= blocksize)
                try self.regrow();

            self.band[self.offset] = data;
        }

        pub fn moveRight(self: *Self) void {
            self.offset += 1;
        }

        pub fn moveLeft(self: *Self) void {
            if (self.offset == 0)
                return;

            self.offset -= 1;
        }
    };
}

pub const Runtime = struct {
    const Self = @This();

    memory: Memory(4096),

    pub fn init(alloc: std.mem.Allocator) !Self {
        return Self{
            .memory = try Memory(4096).init(alloc),
        };
    }

    pub fn deinit(self: *Self) void {
        self.memory.deinit();
    }

    pub fn execProg(self: *Self, program: *std.ArrayList(bytec.BfBytecodeOp)) !void {
        const program_slice = program.items;
        var program_counter: usize = 0;

        const stdout = std.io.getStdOut().writer().any();

        while (program_counter < program_slice.len) {
            const memval = try self.memory.fetch();

            switch (program_slice[program_counter].raw_op) {
                instr.BfInstrEnum.JmpO => {
                    if (memval == 0) {
                        program_counter = program_slice[program_counter].arg.?;
                        continue;
                    }
                },

                instr.BfInstrEnum.JmpC => {
                    if (memval != 0) {
                        program_counter = program_slice[program_counter].arg.?;
                        continue;
                    }
                },

                instr.BfInstrEnum.Add => {
                    try self.memory.post(memval + 1);
                },

                instr.BfInstrEnum.Red => {
                    try self.memory.post(memval - 1);
                },

                instr.BfInstrEnum.Out => {
                    try stdout.writeByte(memval);
                },

                instr.BfInstrEnum.MovR => {
                    self.memory.moveRight();
                },

                instr.BfInstrEnum.MovL => {
                    self.memory.moveLeft();
                },

                else => {
                    unreachable;
                }
            }

            program_counter += 1;
        }
    }
};

