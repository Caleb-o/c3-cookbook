# Using C with C3

> 🚧 This is a work in progress, so it may not be complete or finalised.

We will create a basic wrapper over a C function, then use it within C3. To keep this relatively simple, we'll use the standard file structure of a project as it will help section off our libraries.

## Setup

We can do this by:
```sh
$ c3c init mycproject
```

If you want something minimal to use the compiler directly:
```sh
$ mkdir lib
$ mkdir src
```

Since this is mostly a project surrounding our C code, we will start there. Let's start by creating a directory in the `lib` folder called, "littlec.c3l". It will serve as our library that holds our wrapper code.

> Note the `.c3l` extension of the directory. This is important, so it must be used.

Within our `littlec.c3l` directory, we will have four files:
- `littlec.c`: C implementation code
- `littlec.h`: C header file describing our code
- `littlec.c3i`: C3 interface file, to describe our C code and how it binds to C3
- `manifest.json`: JSON file outlining the library details

To begin with, we will get the manifest out of the way. We don't need too much here for our example, so we can keep this minimal:

```json
{ 
  "provides" : "littlec",
  "c-sources": [ "littlec.c" ],
  "targets" : {
    "linux-x64" : {}
  }
}
```

> I am using Linux, so my target is `linux-x64`. You can list multiple targets here if you want to support many targets.
> If you don't know what to put here, you can use `c3c --list-targets` to see all available targets.

This is a pretty small manifest and we don't need to add anything to our target for this example. For the project to compile, we need to list our target otherwise the compiler will error saying the platform is not supported.

Before we get to the code, lets go over what is here.
- `"provides"`: This is the name of our library. It does not need to be the same as the module name.
- `"c-sources"`: This is a list of our C source files that should be included in the build.
- `"targets"`: As before, these are our supported targets for our library. We can list other properties here to override or append to our global properties.

For more details and a list of properties that are allowed, use `c3c --list-manifest-properties` to view.

### C Code

Okay, now that we've looked into our manifest, we can start writing our tiny wrapper. First, we will create our C header file, as this is only a few lines. Here's our header:

`littlec.h`
```c
#ifndef LITTLEC_H
#define LITTLEC_H

int add(int a, int b);

#endif
```

Obviously the most interesting function we could write here. Just to keep our code simple, we will just be adding two numbers in C and returning that to C3. Now for our implementation:

`littlec.c`
```c
#include "littlec.h"

int add(int a, int b) {
  return a + b;
}
```

And that's it. We can now start wrapping our code with our c3i file. 

`littlec.c3i`
```c++
module littlec;

fn int add(int a, int b) @extern("add");
```

So what is this file doing? First of all, we create a module for our library `littlec`. This will be what we import into our code to use our library. This does not have to be the same as our library name, but it is preferred to keep it the same. If you need to change the module name, you should make a not somewhere to let users know what module is required.

Second, we are using a C3 function signature that reflects our `add` function in C. Just after our signature, we have the `extern` attribute which tells the compiler what symbol we're binding our function to. Our C function is called "add", so we use "add" inside our extern attribute.

And that's our little wrapper completed. Now onto using it.

## Using our Wrapper

We can now use our wrapper within our C3 code. If you created a project, we will be using `src/main.c3`, otherwise create a file within `src` or somewhere close to the lib. Here's our code:

```c++
module cinterop;
import std::io;

// C wrapper module
import littlec;

fn int main()
{
	io::printfn("3 + 4 = %s", littlec::add(3, 4));
	return 0;
}
```

Nothing too crazy here. We can simply import our new library, then we call it within main using the arguments 3 and 4.

### Running

If you're wanting to compile directly:
```sh
$ c3c compile src/main.c3 --obj-out temp --output-dir temp --libdir lib --lib littlec -o helloc
```
Or build and run:
```sh
$ c3c compile-run --run-once src/main.c3 --obj-out temp --output-dir temp --libdir lib --lib littlec
```

> Currently there is a [bug](https://github.com/c3lang/c3c/issues/1503) that requires you use `--obj-out <dir>`.

If you're using using a project:
```sh
$ c3c run
# OR:
$ c3c build
$ ./build/<your_executable>
```

Then finally the output of the executable:
```sh
3 + 4 = 7
```

Congratulations, we have put together a C wrapper in C3! This was quite a simple example to get the idea across, but if you're interested in larger examples or wrapping C libraries, check out the [vendor](https://github.com/c3lang/vendor) repository. This repo contains some libraries that are wrappers over C code. You can open up one of the libraries and checkout their `.c3i` file to see how a more real-world wrapper library is created.