module project::calculator;

import std::io;
import std::core::string;
import std::core::mem;
import std::core::mem::allocator;
import std::collections::range;

def CharRange = range::Range(<char>);
CharRange range = { '0', '9' };

fn void main() {
    String expression = "2 + 3 * 4 / 5";
    float! result = calculate(expression);
    if (catch excuse = result) {
        io::printfn("Failed with error: %s", excuse);
        return;
    }
    io::printfn("Result = %s", result);
}

fault EvalErr {
    BAD_SYNTAX,
}

struct Parser {
    String source;
    usz ip;
    Token current;
}

enum TokenKind : char {
    NUMBER,
    PLUS,
    MINUS,
    STAR,
    SLASH,
    EOF,
}

struct Token {
    TokenKind kind;
    String lexeme;
}

enum NodeType : char {
    BINARY,
    LITERAL,
}

struct BinaryOp {
    Token op;
    Node *lhs;
    Node *rhs;
}

struct Node {
    NodeType type;
    union data {
        BinaryOp binary;
        float number;
    }
}

fn Parser new_parser(String source) {
    return { source, 0, { EOF, "" } };
}

fn char Parser.peek(&self) @inline {
    if (self.at_end()) {
        return '\0';
    }
    return self.source[self.ip];
}

fn void Parser.advance(&self) @inline  {
    self.ip++;
}

fn bool Parser.at_end(&self) @inline  {
    return self.ip >= self.source.len;
}

fn void Parser.skip_whitespace(&self) {
    // Basic whitespace
    while (!self.at_end() && self.peek() == ' ') {
        self.advance();
    }
}

fn Token! Parser.get_token(&self) {
    self.skip_whitespace();
    if (self.at_end()) {
        return { EOF, "" };
    }

    switch (self.source[self.ip]) {
        // Operators
        case '+':
            self.advance();
            return { PLUS, "+" };

        case '-':
            self.advance();
            return { MINUS, "-" };

        case '*':
            self.advance();
            return { STAR, "*" };

        case '/':
            self.advance();
            return { SLASH, "/" };

        // Numbers
        case '0'..'9': return self.make_number()!;

        // Unknown character found
        default: return EvalErr.BAD_SYNTAX?;
    }
}

fn Token! Parser.make_number(&self) {
    usz start = self.ip;
    self.advance(); // Increment as we know the first character

    // Consume numbers
    while (!self.at_end() && range.contains(self.peek())) {
        self.advance();
    }

    if (self.peek() == '.') {
        // Decimal number
        self.advance();

        // Consume numbers again
        while (!self.at_end() && range.contains(self.peek())) {
            self.advance();
        }
    }

    return { NUMBER, (String)self.source[start..self.ip-1] };
}

fn Token! Parser.consume(&self, TokenKind kind) {
    if (self.current.kind == kind) {
        Token current = self.current;
        self.current = self.get_token()!;
        return current;
    }

    // Basic error
    io::printfn("Error: Expected '%s' but received '%s'", kind, self.current.kind);
    return EvalErr.BAD_SYNTAX?;
}

fn Node*! Parser.parse(&self) {
    return self.term()!;
}

fn Node*! Parser.term(&self) {
    Node *node = self.factor()!;

    while (self.current.kind == PLUS || self.current.kind == MINUS) {
        Token op = self.consume(self.current.kind)!;
        node = mem::new(Node, {
            NodeType.BINARY,
            {
                .binary = {
                    op,
                    node,
                    self.factor()!,
                },
            },
        });
    }

    return node;
}

fn Node*! Parser.factor(&self) {
    Node *node = self.primary()!;

    while (self.current.kind == STAR || self.current.kind == SLASH) {
        Token op = self.consume(self.current.kind)!;
        node = mem::new(Node, {
            NodeType.BINARY,
            {
                .binary = {
                    op,
                    node,
                    self.primary()!,
                },
            },
        });
    }

    return node;
}

fn Node*! Parser.primary(&self) {
    // We only have one value, so we make sure it's a number and return
    if (self.current.kind != NUMBER) {
        io::printfn("Error: Expected number but received '%s'", self.current.kind);
        return EvalErr.BAD_SYNTAX?;
    }

    Token t = self.consume(NUMBER)!;

    return mem::new(Node, {
        NodeType.LITERAL,
        {
            .number = t.lexeme.to_float()!!,
        },
    });
}

fn float evaluate(Node *node) {
    switch (node.type) {
        case NodeType.BINARY: return evaluate_binary(node);
        case NodeType.LITERAL: return evaluate_literal(node);
        default: unreachable("UNKNOWN NODE");
    }
}

fn float evaluate_binary(Node *node) {
    BinaryOp *bin = &node.data.binary;
    switch (bin.op.kind) {
        case PLUS:  return evaluate(bin.lhs) + evaluate(bin.rhs);
        case MINUS: return evaluate(bin.lhs) - evaluate(bin.rhs);
        case STAR:  return evaluate(bin.lhs) * evaluate(bin.rhs);
        case SLASH: return evaluate(bin.lhs) / evaluate(bin.rhs);
        default: unreachable("UNKNOWN OPERATOR");
    }
}

fn float evaluate_literal(Node *node) @inline
    => node.data.number;

fn float! calculate(String source) {
    DynamicArenaAllocator dynamic_arena;
    defer dynamic_arena.free();
    
    dynamic_arena.init(1024, allocator::heap());

    mem::@scoped(&dynamic_arena) {
        Parser parser = new_parser(source);
        // Get initial token
        parser.current = parser.get_token()!;

        // Parse and evaluate
        Node *root = parser.parse()!;
        return evaluate(root);
    };
}