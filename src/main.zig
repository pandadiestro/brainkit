const std = @import("std");
const parser = @import("lib/parser.zig");
const runtime = @import("lib/runtime.zig");

fn parseRun(file: *const std.fs.File) !void {
    var new_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer new_arena.deinit();

    var new_parser = try parser.BfParser.init(
        new_arena.allocator(),
        file.reader().any()
    );

    defer new_parser.deinit();

    new_parser.tryLex() catch |lexerr| switch (lexerr) {
        parser.ParseErr.ErrCompilationfail => return,
        else => return lexerr,
    };

    var new_runner = try runtime.Runtime.init(std.heap.page_allocator);
    defer new_runner.deinit();

    try new_runner.execProg(&new_parser.program);
}

pub fn main() !void {
    const parsed_args = try @import("lib/args.zig").parseArgs();
    if (parsed_args.input_file) |infile| {
        try parseRun(&infile);
    } else {
        std.debug.print("no input file was entered!\n", .{});
    }

}

