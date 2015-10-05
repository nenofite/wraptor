# Wraptor

Wraptor brings intelligent text-wrapping to [Textadept](http://foicica.com/textadept/).

## Installation

Clone this repository into the directory `~/.textadept/modules/` to install the
module:

```sh
cd ~/.textadept/modules
git clone git@github.com:nenofite/wraptor.git
```

To activate, add these lines to your `~/.textadept/init.lua` file:

```lua
wraptor = require 'wraptor'

-- Make Ctrl+G wrap the current selection.
keys.cg = wraptor.wrap_selection
```

Substitute `keys.cg` with whatever key combination you prefer.

## Customization

To change the maximum line length used when wrapping text (often referred to as
the wrap width) set the field `wraptor.max_line_length`. The default is 80.
