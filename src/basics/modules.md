# Modules

> 🚧 Work in progress 🚧

[Modules](https://c3-lang.org/references/docs/modules/) in C3 are quite interesting. Every file must start with a module declaration, as such `module mymodule`. A module is a container that namespaces our code. Later on, I will show how modules are our gateway into using generics.

Here's a list of things that will be covered:
- [Using modules and its properties](#using-modules)
- [Generics through modules](#generics-through-modules)

## Using Modules

As mentioned in our [Hello World](hello_world.md) example, we explained that a module is not tied to any file or directory. It was also mentioned that any file with the same module declaration, will be considered the same module and will share code. Let's take a look at what this means:

```c++
// foo.c3
module mymodule;
...

// bar.c3
module mymodule;
...
```

Here we can see that both our `foo` and `bar` files have `mymodule` declared. Some might see this as a potential error, since we're presumably on the same level using the same module. If you're coming from Go, this might be expected that these are the same. However, in C3, I can name these modules whatever I like, even when on the same level. So what if I change my code to this instead?

```c++
// foo.c3
module mymodule;
...

// hello/somewhere/bar.c3
module mymodule;
...
```

I have now moved `bar` into a new directory. Does this mean that I now have two `mymodule` modules? No. No matter where you declare the module, they will always be shared. So both of these are seen as the same module, which makes organisation so much easier. This is where I make the connection to languages with namespaces. If two files use the same namespace, wherever they be in my project files, I expect them to be part of said namespace. This now makes our imports so much easier, as we don't need to follow a path or traverse upwards or from the root. Here's how we would import this:

```c+++
import mymodule;
...
```

We can now use `mymodule` and it's as easy as that.

## Generics through modules

In C3, generics are expressed through modules. This is different to other languages, where you might write something like `<T, U>` on a type or function and be good. With C3, you do this at the module level instead.

```c++
module genericmodule(<Type>);

struct Foo {
  Type bar;
}
```

Since we use the module, how does that look when importing?

```c++
import genericmodule;
```

This is just importing as normal? So how do we use the generic? We can use our `Foo` like this:

```c++
import genericmodule;

Foo(<int>) foo;

// or use define
def IntFoo = Foo(<int>);

IntFoo foo;
```

We can extend our generic module to include a function, that takes the generic value and returns it:

```c++
module genericmodule(<Type>);

struct Foo {
  Type bar;
}

fn Type return_t(Type v) {
  return v;
}
```

Using this function is quite similar:
```c++
import genericmodule;

fn void main() {
  // NOTE: The generic parameter is required here, as well as the module name prefix
  int a = genericmodule::return_t(<int>)(10);
}