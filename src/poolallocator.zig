const std = @import("std");

pub fn PoolAllocator(comptime T: type, comptime capacity: usize) type {
    return struct {
        const Self = @This();
        buffer: [capacity]T = undefined,
        free_list: ?*T = null,

        pub fn init(self: *Self) void {
            for (self.buffer[0 .. capacity - 1], 0..) |*item, i| {
                const next = self.buffer[i + 1];
                @as(*?*T, @ptrCast(item)).* = next;
            }

            @as(*?*T, @ptrCast(&self.buffer[capacity - 1])).* = null;
            self.free_list = &self.buffer[0];
        }

        fn alloc(ctx: *anyopaque, len: usize, alignn: u8, return_address: usize) ?[*]u8 {
            _ = return_address;
            const self: *Self = @ptrCast(@alignCast(ctx));

            if (len != @sizeOf(T) or alignn > @alignOf(T))
                return null;

            const node = self.free_list orelse return null;

            self.free_list = @as(*?*T, @ptrCast(node)).*;

            return @ptrCast(node);
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
            _ = return_address;

            const self: Self = @ptrCast(@alignCast(ctx));

            if (buf.len != @sizeOf(T) or alignn > @alignOf(T)) {
                return;
            }

            const node: *T = @ptrCast(buf.ptr);

            @as(*?*T, @ptrCast(node)).* = self.free_list;
            self.free_list = node;
        }

        pub fn allocator(self: *Self) std.mem.Allocator {
            return std.mem.Allocator{
                .ptr = self,
                .alloc = alloc,
                .resize = resize,
                .free = free,
            };
        }
    };
}

//     fn resize(ctx: *anyopaque, buf: []u8, alignn: u8, new_len: usize, return_address: usize) bool {
//         _ = ctx;
//         _ = buf;
//         _ = alignn;
//         _ = new_len;
//         _ = return_address;
//         return false;
//     }

//     fn free(ctx: *anyopaque, buf: []u8, alignn: u8, return_address: usize) void {
//         _ = ctx;
//         _ = buf;
//         _ = alignn;
//         _ = return_address;
//     }

//     pub fn allocator(self: *PoolAllocator) std.mem.Allocator {
//         return std.mem.Allocator{
//             .ptr = self,
//             .alloc = alloc,
//             .resize = resize,
//             .free = free,
//         };
//     }
// };
