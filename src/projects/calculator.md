# Calculator Evaluator

> 🚧 This is a work in progress, so it may not be complete or finalised.

We are going to create a small project, that can lex, parse and evaluate an expression for a basic calculator. We will try and keep this nice and easy and so we are going to merge a few things together for simplicity. You can see the full example at [the end](#final-code).

## Getting Started

With this example, we can just use a single script that I am going to call `calculator.c3`. If you want to use a project, you can do `c3c init calculator`, move into the directory and open `src/main.c3` in your editor.

To begin, we will import everything the project requires up front, so we don't need to worry about this later. We will also write up our main function too:

```c++
{{#include ../../examples/projects/calculator.c3::20}}
```

We import all the necessary modules required for the project, which includes allocators, string functions, io for printing and the range type just to make lexing numbers simpler. In our main function, we create an `expression` variable, which will be the code our evaluator runs. Next we pass it to the `calculate` function, which returns an optional `float`, as this can fail. We handle the error case, then print the result if all goes well. This will make more sense once we get to implementing the code.

> I've opted to write my own lexer and parser, as using a library is overkill.
> Writing your own lexer and parser is also fun and can also be quite simple.

### Tokens

Tokens are a small structure that are used to annotate pieces of code. In a programming language, these can be things like a keyword, operators, identifiers etc. Since we're making a calculator, this structure will be pretty simple, as we only have operators and numbers.

```c++
{{#include ../../examples/projects/calculator.c3:32:44}}
```

Our `TokenKind` is a simple enum, which will denote what the token represents. We also include `EOF` as a way to know we're done. The `Token` is also quite simple in this case, we have the `kind` and the `lexeme`. The lexeme will be a slice that we will use to parse the `float` for our numbers. We can also use this to print nicer error messages if we wanted to.

### The "Lexer"

Our lexer is the system that will take our source and convert it into a stream of tokens. This is the first merge we will do with our types, where it will actually act as the parser as well. For such a small example like our calculator, this is fine, but you might want to have a lexer and parser seperately for more serious projects. Here is how we will define the lexer/parser combo:

```c++
{{#include ../../examples/projects/calculator.c3:26:30}}
```

Quite a small structure too, as it takes our source, the `ip` for keeping track of where we are in the source, then a `Token` that we will use later for parsing. Let's create a small helper function to create a parser for us:

```c++
{{#include ../../examples/projects/calculator.c3:65:67}}
```

We simply pass the source in, then 0 out the rest of the fields. We put a dummy token in for the `current` token field, as we will set it later. Before we write the lexing function, we will setup a few methods to make lexing easier.

```c++
{{#include ../../examples/projects/calculator.c3:69:89}}
```

These are some pretty simple methods, to help us get the current char, advance, check if we're at the end of the source and for skipping whitespace.

> In a more complex lexer, we would account for tabs, newlines, breaks etc in our `skip_whitespace`. We might also have variable `peek` to look-ahead as well as viewing the current char.

Now for the meat of our lexer, the function that will generate a token. For our calculator, we can write this pretty easily.

```c++
{{#include ../../examples/projects/calculator.c3:91:121}}
```

This will skip whitespace, if we're at the end, then generate an `EOF` token. Then we check the current `char` and see whether it's an operator, or if it's a number. Otherwise, we will return a fault of `BAD_SYNTAX`. You may also notice the `make_number` method and we will implement that shortly, but let us create the fault.

```c++
{{#include ../../examples/projects/calculator.c3:22:24}}
```

Nothing too crazy for our fault here. We will also re-use this in our parser, when we get an unexpected symbol. Back to the lexer! We can now look at lexing a number:

```c++
{{#include ../../examples/projects/calculator.c3:123:143}}
```

Almost the same size as our `get_token` method itself! We capture the current index of our source and then advance, as we have already checked the first character. We then advance as long as there is a number as the current char. Then we check for a `.` to support basic decimal numbers, then advance again for trailing numbers. After that, we then slice our source to capture the number, using the `start` variable we created for our anchor.

That's the end of our lexing methods and now we head over to parsing.

### Parsing Expressions

This is where the fun begins! Parsing is the step where our syntax matters. For a programming language, this is how we might collect variables, functions, structures etc into an AST. We will still do this for our calculator, but our AST will be pretty simple. All we need for the calculator, is a binaryop and a literal.

> As an exercise, you can also implement unary expressions, like negative numbers.

Since our AST is simple, we can define it in a few lines of code.

```c++
{{#include ../../examples/projects/calculator.c3:46:63}}
```

We create an enum so we can tag our `Node` to know what it contains. Our `BinaryOp` is a node that represents something like `1 + 2`. Then we have our `number` which is just a `float` that we will collect from our token.

As before with our lexer, we will create a helper method for consuming tokens:

```c++
{{#include ../../examples/projects/calculator.c3:145:155}}
```

If the current token in our parser matches the kind provided, it will consume the token, fetch the next token and return the old token. This is so we can capture the token and use it later. If the token doesn't match, then we print a basic error message and return a fault. This is the same fault used before in our `get_token`.

This will be a large section of code, but it will implement the entire parsing of expressions.

```c++
{{#include ../../examples/projects/calculator.c3:157:216}}
```

We are using a recursive descent parser, so that means we call one function after another and recursively (basically). So we start in `parse`, which then calls `term`, then `factor` then `primary`. So on a call to `parse`, we start in parse and end up in primary, then work our way back up the call stack. In both `term` and `factor` we have similar code checking for operators, then setting the node to a `BinaryOp`. Notice how we pass `node` in as the second argument, then call the next function down eg. term will call factor. This is used for parsing precedence, so we can evaluate our expression correctly.

That is now the end of the parser. A simple helper function for consuming tokens, then the parsing functions.

### Evaluating our AST

To start our evaluation, we will implement the `calculate` function we saw in `main`. This is our entry that will handle parsing and evaluating.

```c++
{{#include ../../examples/projects/calculator.c3:240:}}
```

To keep our memory handling simple, we use the `DynamicArenaAllocator` which will expand as we need and free all the memory at the end. Notice the `mem::@scoped(&dynamic_arena)`. This is where our `mem::new` calls end up allocating to. Let's dive into `evaluate`:

```c++
{{#include ../../examples/projects/calculator.c3:218:224}}
```

This function is pretty safe, as the `unreachable` means we probably haven't implemented something. Our calculator only has two nodes, so our cases are covered here. Something to note, is that every `evaluate_*` function returns a `float`. Since this is our main value type in the calculator, we keep things simple.

> In a scripting language using tree-walk evaluation (which is what this implementation is), we might use something like a `Value` type to express more complex types like strings, bools and functions.

We can take a look at the simplest function: `evaluate_literal`

```c++
{{#include ../../examples/projects/calculator.c3:237:238}}
```

Since our AST node for the literal holds the value, we can simply return the number. Next is the `evaluate_binary` function, which will do the work of operators:

```c++
{{#include ../../examples/projects/calculator.c3:226:235}}
```

For sanity reasons, we take reference to the `binary` field so we can juse use a variable throughout. We switch on the operator's token kind, then return the evaluation of `lhs <op> rhs`. If we were to implement another operator, our unreachable will trigger to let you know at run-time.

And that's it! We've implemented a basic parser and evaluator for a calculator! Below is the result of running our code and the full source in case something is broken. If you want to try more examples, change the `expression` variable to something else and see what happens.

> If you want to do more, try to implement negative numbers and the `%` operator.
> Languages are cool and if you thought this was fun, take a look at [Crafting Interpreters](https://craftinginterpreters.com/) by Bob Nystrom.

## Result

Running the project:
```sh
$ c3c run
```

Using the compiler directly:
```sh
$ c3c compile-run --run-once calculator.c3
```

Output:
```sh
Program linked to executable 'calculator'.
Launching ./calculator
Result = 4.400000
Program completed with exit code 0.
```

## Final Code

```c++
{{#include ../../examples/projects/calculator.c3}}
```