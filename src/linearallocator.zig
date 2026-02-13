const std = @import("std");

const LinearAllocator = struct {
    buffer: []u8,
    offset: usize,

    pub fn init(buffer: []u8) LinearAllocator {
        return .{
            .buffer = buffer,
            .offset = 0,
        };
    }

    fn alloc(ctx: *anyopaque, len: usize, alignn: u8, return_address: usize) ?[*]u8 {
        _ = return_address;
        const self: *LinearAllocator = @ptrCast(@alignCast(ctx));

        const align_offset = std.mem.alignForward(self.offset, alignn);

        if (align_offset + len > self.buffer.len) {
            return null;
        }

        const ptr = self.buffer.ptr + align_offset;
        self.offset = align_offset + len;

        return ptr;
    }

    fn resize(ctx: *anyopaque, buf: []u8, alignn: u8, new_len: usize, return_address: usize) bool {
        _ = ctx;
        _ = buf;
        _ = alignn;
        _ = new_len;
        _ = return_address;
        return false;
    }

    fn free(ctx: *anyopaque, buf: []u8, alignn: u8, return_address: usize) void {
        _ = ctx;
        _ = buf;
        _ = alignn;
        _ = return_address;
    }

    pub fn allocator(self: *LinearAllocator) std.mem.Allocator {
        return std.mem.Allocator{
            .ptr = self,
            .alloc = alloc,
            .resize = resize,
            .free = free,
        };
    }
};
