const std = @import("std");

pub const TokeType = enum { Illegal, Plus, Minus, Asterisk, Slash, Integer };

pub const Token = struct { Type: TokeType, Literal: []const u8 };
