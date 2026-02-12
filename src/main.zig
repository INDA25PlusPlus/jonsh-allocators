const std = @import("std");
const jonsh_allocators = @import("jonsh_allocators");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    try jonsh_allocators.bufferedPrint();
}
