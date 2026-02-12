const std = @import("std");

const LinearAllocator = struct {
    buffer: []u8,
    offset: usize,
};
