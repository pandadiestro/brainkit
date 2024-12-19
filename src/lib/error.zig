const std = @import("std");
const instr = @import("instr.zig");

pub const ErrContext = struct {
    offset: usize = 0,
    message: []const u8,
    window: ?[]u8 = null,
};

const window: u32 = 10;

fn printWindow(ctx: *const ErrContext, win: []u8) void {
    for(0..win.len) |index| {
        switch (win[index]) {
            '\n' => std.debug.print("\\n", .{}),
            '\r' => std.debug.print("\\r", .{}),
            else => std.debug.print("{c}", .{
                win[index]
            }),
        }
    }

    std.debug.print("\n", .{});

    for (0..ctx.offset) |_| {
        std.debug.print(" ", .{});
    }

    std.debug.print("^\n", .{});
}

pub fn handleErrWithCtx(ctx: *const ErrContext) void {
    if (ctx.window) |window_slice| {
        printWindow(ctx, window_slice);
    }

    std.debug.print("{s}\n", .{
        ctx.message,
    });
}







