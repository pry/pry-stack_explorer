pry-stack_explorer
===========

_Walk the stack in a Pry session_

---

Pry::StackExplorer is a plugin for [Pry](http://pry.github.com)
that allows navigating the call stack.

From the point a Pry session is started, the user can move up the stack
through parent frames, examine state, and even evaluate code.

Unlike `ruby-debug`, pry-stack_explorer incurs no runtime cost and
enables navigation right up the call-stack to the birth of the
program.

The `up`, `down`, `frame` and `stack` commands are provided. See
Pry's in-session help for more information on any of these commands.

## Usage
Provides commands available in Pry sessions.

Commands:
* `up`/`down` - Move up or down the call stack
* `frame [n]` - Go to frame *n*
* `stack` - Show call stack


## Install

In Gemfile:
```rb
gem 'pry-stack_explorer', '~> 0.6.0'
```

```
gem install pry-stack_explorer
```

* Read the [documentation](http://rdoc.info/github/banister/pry-stack_explorer/master/file/README.md)
* See the [wiki](https://github.com/pry/pry-stack_explorer/wiki) for in-depth usage information.


### Branches and compatible Ruby versions
* v0.5, v0.6: Ruby 2.6+, Pry 0.13+
* v0.4.11+: Ruby 2.5, Pry 0.12+ (branch `0-4` – end-of-life in March 2021)
* v0.4.9.3: Older versions (unsupported)

Example:
--------
Here we run the following ruby script:
```Ruby
require 'pry-stack_explorer'

def alpha
  x = "hello"
  beta
  puts x
end

def beta
  binding.pry
end

alpha
```

We wander around the stack a little bit, and modify the state of a frame above the one we `binding.pry`'d at.

[![asciicast](https://asciinema.org/a/257713.svg)](https://asciinema.org/a/257713)

Output from above is `Goodbye` as we changed the `x` local inside the `alpha` (caller) stack frame.


License
-------
Released under the [MIT License](https://github.com/pry/pry-stack_explorer/blob/master/LICENSE) by John Mair (banisterfiend) and contributors

Contributions to this gem are released under the same license.
