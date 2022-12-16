# Jean-Lua

## Overview

Jean-Lua is a generic, dependency free lua library providing usefull common
constructs, algorithm implementations and tools to program in Lua.

The goals seeked here are :

* No dependency, except the lua standard library.
* Compatibility with Lua 5.1 to 5.4 and LuaJIT.
* Genericity : I put in here everything that I expect to be of some utility in
  83.2% of softwares. So no sockets, and no image manipulation.

Performance isn't the main concern : it's written in pure lua. If your
application is performance-critical, you should use C. However, any
optimisation idea or patch is much welcome, as the goal isn't either to have
the slowest library possible.

## Features

For now, Jean-Lua provides the following features :

* A **[class model](/usage/object)**, supporting single inheritance, properties,
  and implementing various checks, like method redefinition, or read-only
  property access.

* A **[functional-ish iterator](/usage/iterators)**, allowing to map, reduce,
  filter elements and all that kind of funky stuff. Allows to collect items
  in one of the provided [containers](/usage/containers) when you're done
  iterating around.

* The said **[containers](/usage/containers)**, namely a
  [list](/usage/containers#list), a [map](/usage/containers/#map). One day
  I'll get some motivation and implement an ordered map, a multimap, a set
  a queue, and an ordered set.

* A **[unit test framework](/usage/unit-tests)**, allowing you to run tests, with
  mocks, fixtures.

* A **[hierarchical logger](/usage/logging)**, to log all the errors that occurs
  in your broken tests.

* 
