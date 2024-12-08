const std = @import("std");

const input = @embedFile("input.txt");

pub fn parse(allocator: std.mem.Allocator) !std.ArrayList(std.ArrayList(u32)) {

  var iter = std.mem.split(u8, input, "\n");
  
  var reports = std.ArrayList(std.ArrayList(u32)).init(allocator);

  while (iter.next()) | line | {
    var report = std.ArrayList(u32).init(allocator);
    var numbers = std.mem.split(u8, line, " ");

    while (numbers.next()) |number| {
      try report.append(try std.fmt.parseInt(u32, number, 10));
    }

    try reports.append(report);
  }

  return reports;
}


pub fn main() !void {
  var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
  defer _ = gp.deinit();

  const reports = try parse(gp.allocator());
  defer reports.deinit();

  std.log.debug("reports: {any}", .{reports});
}
