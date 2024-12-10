const std = @import("std");

const input = @embedFile("input.txt");

const Direction = enum { unknown, increasing, decreasing };

const Report = struct { data: []const u8,

  fn isSafe(self: *const Report) !bool {
    const maxIncrease: i32 = 3;
    var prev: i32 = 0;
    var direction: Direction = .unknown;

    var numbers = std.mem.split(u8, self.data, " ");

    std.log.info("Validating report: {s}", .{self.data});

    while (numbers.next()) | number | {
      const parsed = try std.fmt.parseInt(i32, number, 10);
      std.log.debug("Comparing numbers: prev{d} & parsed{}", .{prev, parsed});
    
      if (prev == 0) {
        std.log.debug("Setting initial number", .{});
        prev = parsed;
        continue;
      }

      if (direction == .unknown) {
        if (prev < parsed) {
          direction = .increasing;
          std.log.debug("Setting direction to: {any}", .{direction});
        } else if (prev > parsed) {
          direction = .decreasing;
          std.log.debug("Setting direction to: {any}", .{direction});
        } else { 
          std.log.debug("numbers the same, so report unsafe", .{});
          return false;
        }
      }

      if (direction == .increasing) {
        if (prev >= parsed) {
          std.log.debug("Oh no, Backwards: prev {d} & parsed {d}", .{prev, parsed});
          return false;
        }

        if (prev + maxIncrease < parsed) {
          std.log.debug("Oh no, to high: prev {d} & parsed {d}", .{prev, parsed});
          return false;
        }
      }

      if (direction == .decreasing) {
        if (prev <= parsed){
          std.log.debug("Oh no, Backwards: prev {d} & parsed {d}", .{prev, parsed});
          return false;
        }

        if (prev - maxIncrease > parsed){
          std.log.debug("Oh no, to high: prev {d} & parsed {d}", .{prev, parsed});
          return false;
        }
      }
      
      prev = parsed;
    }

    return true;
  }
};



pub fn parse(allocator: std.mem.Allocator) !std.ArrayList(Report) {

  var iter = std.mem.split(u8, input, "\n");
  var reports = std.ArrayList(Report).init(allocator);

  while (iter.next()) | line | {
    if (line.len == 0) continue; // Last line is empty, so ignore it

    const report = Report{ .data = line, }; 

    try reports.append(report);
  }

  return reports;
}


pub fn main() !void {
  var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
  defer _ = gp.deinit();

  const reports = try parse(gp.allocator());
  defer reports.deinit();

  var safeReports: usize = 0;

  for (reports.items) | report | {
    if (try report.isSafe()) {
      std.log.info("Report {s} is safe", .{report.data});
      safeReports = safeReports + 1;
    } else {
      std.log.info("Report {s} is not safe", .{report.data});
    }
  }

  std.log.info("Amount of safe reports: {d}", .{safeReports});
}
