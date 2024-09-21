# Hello World!

Let's write the classic example, Hello World! But before that, we have two options with how to proceed:
- [Running directly](#running-directly)
- [Using a project](#using-a-project)

## Running directly

We can create a new file with the `.c3` extension. Then we can write this code:
```c++
{{#include ../../examples/basics/hello_world.c3}}
```

We will use the compiler to build, run and then dispose of the executable:
```sh
$ c3c compile-run --run-once main.c3
```

This should then print to the console
```sh
Program linked to executable 'myproject'.
Launching ./myproject
Hello, World!
Program completed with exit code 0.
```

You can also just compile the file and run the executable directly:

```sh
$ c3c compile main.c3 -o hello
$ ./hello

Hello, World!
```

[Done](#explaining-our-program)

## Using a project

Creating a project is quite simple in C3. We can use the `c3c` executable to initialise, build and run our project.

Let's create a new project:
```sh
$ c3c init myproject
$ cd myproject
```

We now have a new project directory and this would have created a few directories within it, a license, a `project.json` and a readme. This includes the `build` directory, which is where your project will be compiled into. In C3 we use the `src` directory and this is where you will find the `main.c3` file. You can see more details about project structure in the [C3 guide](https://c3-lang.org/guide/my-first-project/).

Let's open the main file `src/main.c3` in your editor and write this code:
```c++
{{#include ../../examples/basics/hello_world.c3}}
```

We can now run this code with:
```sh
$ c3c run
```

This should then print to the console
```sh
Program linked to executable 'myproject'.
Launching ./myproject
Hello, World!
Program completed with exit code 0.
```

### Explaining our program

You have now written your first C3 program. Let's break down what is happening in our code. We can start with the first line:

```c++
module myproject;
```

Every file should start with a module name, if we omit this, then the compiler will try its best to generate one using the file. We can think of a module like a namespace, as each file that has the same module name is considered the same module. Module names are not tied to files or the directory they are in, so it is up to you to name them correctly. To avoid clashing, we must use longer and/or more detailed names. This could be something like `projectname::foo::bar::baz`.

```c++
import std::io;
```

Next is our import. This is how we import modules in C3. One thing that might confuse people who might be used to namespaces, is that this is actually a sub-namespace/module within `std`. However, as described above, this is just a name. You cannot create sub-modules as you might expect from other languages, but this is just a naming style to keep things organised logically.

```c++
fn void main() {
    io::printn("Hello, World!");
}
```

Functions in C3 use the `fn` keyword to denote a function declaration. It is then followed by the return type and then a function name and its parameters. This should look pretty familiar for anyone who's used a C-style language. The interesting thing here is our `io::printn`. If you tried to remove the `io::` prefix, you will see this error:

```sh
Error: Functions from other modules must be prefixed with the module name.
```

Any function that comes from a different module, ***must*** be prefixed with its module name. This helps the reader also understand where this function comes from. We will see this often later, when it comes to types as well. More with modules [here](modules.md).

> There is another way we can write this function. This will be familiar for those who have used JavaScript:
> ```c++
> fn void main() => io::printn("Hello, World!");
> ```
> 
> It is possible to write a single expression function, using the `=>` arrow syntax. This is useful for writing simple functions that return a value.

This was probably quite a long explanation of Hello World, but this is essentially how this book should be structured. We will write an example, then give an explanation on the hows and why. Hopefully this can help give better understanding of the code written and leaves you both curious for more and with questions answered.