pry-stack_explore
===========

(C) John Mair (banisterfiend) 2011

_Walk the stack in a Pry session_

`pry-stack_explorer` is a plugin for the [Pry](http://pry.github.com)
REPL that enables navigation of the call-stack.

From the point a Pry session is started, you can move up the stack
through parent frames, examine state, and even evaluate code.

Unlike `ruby-debug`, `pry-stack_explorer` incurs no runtime cost and
enables navigation right up the call-stack to the birth of your
program.

`pry-stack_explorer` is currently designed to work on MRI and
Ruby 1.9.2+ (including 1.9.3). Support for other Ruby versions and
implementations is planned for the future.

The `up`, `down`, `frame` and `show-stack` commands are provided.

* Install the [gem](https://rubygems.org/gems/pry-stack_explore): `gem install pry-stack_explore`
* Read the [documentation](http://rdoc.info/github/banister/pry-stack_explore/master/file/README.md)
* See the [source code](http://github.com/banister/pry-stack_explore)

Example: Example description
--------

Example preamble

    puts "example code"

Features and limitations
-------------------------

Feature List Preamble

Contact
-------

Problems or questions contact me at [github](http://github.com/banister)


License
-------

(The MIT License)

Copyright (c) 2011 John Mair (banisterfiend)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
