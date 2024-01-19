const std = @import("std");

const Token = @import("./token.zig");

const Lexer = struct {
    input: []const u8,
    position: usize,
    read_position: usize,
    ch: u8,

    fn init(input: []const u8) Lexer {
        var lexer = Lexer{ .input = input, .position = 0, .read_position = 0, .ch = 0 };
        lexer.readChar();
        return lexer;
    }

    pub fn nextToken(this: *@This()) Token.Token {
        this.skipWhiteSpace();

        var token: Token.Token = switch (this.ch) {
            '+' => .{ .Type = .Plus, .Literal = "+" },
            '-' => .{ .Type = .Minus, .Literal = "-" },
            '*' => .{ .Type = .Asterisk, .Literal = "*" },
            '/' => .{ .Type = .Slash, .Literal = "/" },
            '0'...'9' => return .{ .Type = .Integer, .Literal = this.readNumber() },
            else => .{ .Type = .Illegal, .Literal = "" },
        };
        this.readChar();
        return token;
    }

    fn readChar(this: *@This()) void {
        if (this.read_position >= this.input.len) {
            this.ch = 0;
        } else {
            this.ch = this.input[this.read_position];
        }
        this.position = this.read_position;
        this.read_position += 1;
    }

    fn readNumber(this: *@This()) []const u8 {
        var position = this.position;
        while (std.ascii.isDigit(this.ch)) {
            this.readChar();
        }
        return this.input[position..this.position];
    }

    fn skipWhiteSpace(this: *@This()) void {
        while (std.ascii.isWhitespace(this.ch)) {
            this.readChar();
        }
    }
};

test "Lexer" {
    const input =
        \\2+2
        \\3++3
        \\2 - 2
        \\5    
        \\*
        \\                  5
        \\5                                         /3
    ;

    var expected = [_]Token.Token{
        .{ .Type = .Integer, .Literal = "2" },
        .{ .Type = .Plus, .Literal = "+" },
        .{ .Type = .Integer, .Literal = "2" },
        .{ .Type = .Integer, .Literal = "3" },
        .{ .Type = .Plus, .Literal = "+" },
        .{ .Type = .Plus, .Literal = "+" },
        .{ .Type = .Integer, .Literal = "3" },
        .{ .Type = .Integer, .Literal = "2" },
        .{ .Type = .Minus, .Literal = "-" },
        .{ .Type = .Integer, .Literal = "2" },
        .{ .Type = .Integer, .Literal = "5" },
        .{ .Type = .Asterisk, .Literal = "*" },
        .{ .Type = .Integer, .Literal = "5" },
        .{ .Type = .Integer, .Literal = "5" },
        .{ .Type = .Slash, .Literal = "/" },
        .{ .Type = .Integer, .Literal = "3" },
    };

    var lexer = Lexer.init(input);

    for (expected) |token| {
        try std.testing.expectEqualDeep(token, lexer.nextToken());
    }
}
