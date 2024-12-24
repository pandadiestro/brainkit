const std = @import("std");

pub const ArgsError = error {
    ErrNoOutName,
    ErrUnknownFlag,
    ErrCorruptedArgset,
};

pub const SolvedArgs = struct {
    input_file: ?std.fs.File = null,
    output_file: ?std.fs.File = null,
    repl_mode: bool = false,
};

pub fn parseArgs() !SolvedArgs {
    var ret = SolvedArgs{};

    var args = std.process.args();
    if (!args.skip())
        return ArgsError.ErrCorruptedArgset;

    while (args.next()) |arg| {
        if (arg.len == 0)
            continue;

        if (arg[0] != '-') {
            ret.input_file = try std.fs.cwd().openFile(arg, .{});
            continue;
        }

        if (arg.len == 1) {
            ret.input_file = std.io.getStdIn();
            continue;
        }

        switch (arg[1]) {
            'o' => {
                if (args.next()) |outname| {
                    ret.output_file = try std.fs.cwd().openFile(outname, .{});
                } else {
                    return ArgsError.ErrNoOutName;
                }
            },

            'r' => {
                ret.repl_mode = true;
            },

            else => return ArgsError.ErrUnknownFlag,
        }
    }

    return ret;
}


