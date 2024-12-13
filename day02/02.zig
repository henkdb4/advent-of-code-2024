const std = @import("std");

const input = @embedFile("input.txt");

const Direction = enum { unknown, increasing, decreasing };

const Report = struct {
    levels: std.ArrayList(i32),
    // # test new idea
    // I need ints parsed before using them, so i am gonna convert them into a list. 
    fn init(allocator: std.mem.Allocator, data: []const u8 ) !Report { 
      var levels = std.ArrayList(i32).init(allocator);

      var iter = std.mem.split(u8, data, " ");

      while (iter.next()) |level|
        try levels.append(try std.fmt.parseInt(u8, level, 10));

      return Report{ .levels = levels,};
    }

    fn getDirection(self: *const Report) Direction {
    const first = self.levels.items[0];
    const last = self.levels.items[self.levels.items.len - 1];
      if (first < last) {
          return .increasing;
      } else if (first > last) {
          return .decreasing;
      }
      return .unknown;
    }

    fn calculateFaults(self: *const Report) !usize {
    
      // Calculate increase and decrease based on firsl last, ipv first second
      // when fault, dampen number by not assigning prev. 
      // When first fault, dampen by just continuing. 

      var prev: i32 = 0;
      var direction: Direction = self.getDirection();
      var faults: usize = 1;

      std.log.info("Validating report: {any}", .{self.levels.items});
      std.log.debug("Direction is: {any}", .{direction});

      for (self.levels.items) |number| {

          std.log.debug("Comparing numbers: prev{d} & parsed{}", .{ prev, number });

          if (prev == 0) {
              std.log.debug("Setting initial number", .{});
              prev = number;
              continue;
          }

          if (direction == .unknown) {
              if (prev < number) {
                  direction = .increasing;
                  std.log.debug("Setting direction to: {any}", .{direction});
              } else if (prev > number) {
                  direction = .decreasing;
                  std.log.debug("Setting direction to: {any}", .{direction});
              }
          }
          
          if (Report.isFaulty(direction, prev, number)) faults = faults + 1;
          prev = number;
      }

      return faults;
    }

    fn isFaulty(direction: Direction, prev: i32, parsed: i32) bool {
        const maxIncrease: i32 = 3;

        if (prev == parsed) return true;

        if (direction == .increasing) {
            if (prev >= parsed) {
                std.log.debug("Oh no, Backwards: prev {d} & parsed {d}", .{ prev, parsed });
                return true;
            }

            if (prev + maxIncrease < parsed) {
                std.log.debug("Oh no, to high: prev {d} & parsed {d}", .{ prev, parsed });
                return true;
            }
        }

        if (direction == .decreasing) {
            if (prev <= parsed) {
                std.log.debug("Oh no, Backwards: prev {d} & parsed {d}", .{ prev, parsed });
                return true;
            }

            if (prev - maxIncrease > parsed) {
                std.log.debug("Oh no, to high: prev {d} & parsed {d}", .{ prev, parsed });
                return true;
            }
        }

        return false;
    }
};

pub fn parse(allocator: std.mem.Allocator) !std.ArrayList(Report) {
    var iter = std.mem.split(u8, input, "\n");
    var reports = std.ArrayList(Report).init(allocator);

    while (iter.next()) |line| {
        if (line.len == 0) continue; // Last line is empty, so ignore it

        const report = try Report.init(allocator, line);

        try reports.append(report);
    }

    return reports;
}

pub fn main() !void {
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();

    var arena = std.heap.ArenaAllocator.init(gp.allocator());
    defer arena.deinit();

    const reports = try parse(arena.allocator());
    defer reports.deinit();

    var safeReports: usize = 0;

    for (reports.items) |report| {
        const errors = try report.calculateFaults();
        if (errors > 0) {
            std.log.info("Report {any} is not safe, it has {} faults", .{report.levels.items, errors});
        } else {
            std.log.info("Report {any} is safe", .{report.levels.items});
            safeReports = safeReports + 1;
        }
    }

    std.log.info("Amount of safe reports: {d}", .{safeReports});
}
