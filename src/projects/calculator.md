# Calculator Evaluator

> 🚧 This is a work in progress

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