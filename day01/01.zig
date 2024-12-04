const std = @import("std");
const ArrayList = std.ArrayList;

const input = @embedFile("input.txt");

const locations_amount = 50;

pub fn main() !void {
    // parse the two lists
    var iter = std.mem.split(u8, input, "\n");

    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();

    var left_list = ArrayList(i32).init(gp.allocator());
    defer left_list.deinit();
    var right_list = ArrayList(i32).init(gp.allocator());
    defer right_list.deinit();

    while (iter.next()) |line| {
        if (line.len == 0) continue; // Last line is empty, so ignore it
        std.log.info("{s}", .{line});

        var pair = std.mem.split(u8, line, "   ");

        const num_left = try std.fmt.parseInt(i32, pair.next().?, 10);
        try left_list.append(num_left);

        const num_right = try std.fmt.parseInt(i32, pair.next().?, 10);
        try right_list.append(num_right);
    }

    // sort each list
    std.mem.sort(i32, left_list.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, right_list.items, {}, comptime std.sort.asc(i32));

    var dist: u32 = 0;
    for (left_list.items, right_list.items) |left, right| {
        std.log.info("{d}   {d}", .{ left, right });
        // calc diff between two
        // and sum them up
        dist = dist + @abs(left - right);
    }

    std.log.info("Distance between lists: {d}", .{dist});

    // Difference hoeveel komt value uit lijst 1 in lijst 2 voor (value * amount in 2).

    // Eerst per nummer bekijken hoevaak hij voorkomt?
    var counts: [100_000]u8 = undefined;   // 5 nums so max 100.000
    
    @memset(&counts, 0);

    for (right_list.items) | num | {
        counts[@intCast(num)] = counts[@intCast(num)] + 1;
    }
     
var similarity: i32 = 0;

    // Daarna opzoeken per waarden?
    for (left_list.items) | num | {
        similarity = similarity + (num * counts[@intCast(num)]);
    }

    std.log.info("Similarity between lists: {d}", .{similarity});

    // Anders loop ik per nummer door de lijst, lijkt mij enorm lang te duren...
}
