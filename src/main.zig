const std = @import("std");
const parser = @import("lib/parser.zig");
const runtime = @import("lib/runtime.zig");

pub fn main() !void {
    const infile = std.io.getStdIn().reader();

    var new_parser = try parser.BfParser.init(infile.any());
    defer new_parser.deinit();

    new_parser.tryLex() catch |lexerr| switch (lexerr) {
        parser.ParseErr.ErrCompfail => return,
        else => return lexerr,
    };

    //for (new_parser.program.items, 0..) |bytecode, i| {
    //    std.debug.print("{}: {}\n", .{
    //        i,
    //        bytecode,
    //    });
    //}

    var new_runner = try runtime.Runtime.init(std.heap.page_allocator);
    defer new_runner.deinit();

    try new_runner.execProg(&new_parser.program);
}

