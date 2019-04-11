# Flight Inventory Diagrams

A diagram rendering plugin for Flight Inventory.

## Prerequisites

1. Working Flight Inventory installation -- currently requires the `dev/plugins-concept` branch
2. Some data to render, specifically, a port map for an asset

## Installation

Install the plugin:

```
# $INVENTORY_ROOT is the root of your Flight Inventory installation.
cd $INVENTORY_ROOT/plugins
git clone https://github.com/alces-software/flight-inventory-diagrams
cd ..
```

## Usage

Set up a map (if you don't have one):

```
flight inventory modify map -c example-switch
```

Set some layout parameters:

```
flight inventory modify other map_layout=t-l-v example-switch
flight inventory modify other map_width=24 example-switch
flight inventory modify other map_height=2 example-switch
```

Render an SVG representation of `example-switch`:

```
flight inventory show document switch.svg example-switch > example-switch.svg
```

You can open the `example-switch.svg` file directly in your browser.

Render a Markdown document containing some information and the SVG image:

```
flight inventory show document switch.md example-switch > example-switch.md
```

The rendered document contains a title, a base64-encoded SVG image and
a table that needs to be passed through a Markdown renderer to be
rendered to HTML for display, i.e. your favourite web-based GUI.

## Configuration

The initial example templates (`switch.md.erb` and `switch.svg.erb`)
provide a small number of configuration values:

 * `width`: number of ports wide
 * `height`: number of ports high
 * `layout`: port numbering method, one of:
   * `t-l-v`: top-left is port 1, numbering proceeds vertically
   * `t-l-h`: top-left is port 1, numbering proceeds horizontally
   * `t-r-v`: top-right is port 1, numbering proceeds vertically (in reverse)
   * `t-r-h`: top-right is port 1, numbering proceeds horizontally (in reverse)
   * as above, but for `b-l-v`, `b-l-h` etc. where port 1 is at the bottom

The diagram plugin has an additional number of configuration values
which can be tweaked by the creation of a new template:

 * Drawing:
   * `truncate_at` - number of characters allowed in text labels before being truncated (default: `9`)
   * `embed` - whether SVG elements suitable for embedding in HTML should be produced (`true`) or an SVG document should be created (`false`) (default: `false`)
 * Layout:
   * `width`, `height` and `layout` as above
   * `ports` - (alternative to `width` and `height`) specify total number of ports of asset
   * `rows` - specify number of rows the `ports` value should be divided into
   * `first_port` - number of the first port (default: `1`)
 * Style:
   * `style_opts` - a hash containing any of the following which governs the style of the drawing:
     * `port_width` - width of a port (default: `50`)
     * `port_height` - height of a port (default: `50`)
     * `padding` - padding between unit/row and ports (default: `5`)
     * `margin` - margin between edge of drawing and unit/rows (default: `10`)
     * `radius` - border radius for unit/rows and ports (default: `10`)
     * `bg_colour` - background colour of drawing (default: `#ddd`)
     * `unit_colour` - colour to use for the unit/rows (default: `#666`)
     * `port_colour` - colour to use for ports (default: `#000`)
     * `port_font_size` - font size to use for port numbers (default: `30`)
     * `name_font_size` - font size to use for labels (default: `25`)
     * `name_pad_factor` - factor to use for spacing between units/rows (default: `(name_font_size/16.0)*10`)
     * `name_colour` - colour to use for labels (default: `#5588cc`)
     * `name_colours` - hash of different colours for "tagged" labels (default: `{default: name_colour}`)

### Tagged labels

A label in the map can be tagged as a particular type and coloured
differently within the diagram by suffixing it with `:<tag>`.  As an
example, the default configuration colours the `switch` tag as green
and the `bmc` tag as purple.

To make use of this feature, set the values in your map to be, for
e.g. `coresw1:switch`, `node005:bmc`.

You can use arbitrary tags and configure using the `name_colours`
style option as described above.

## Known issues/potential enhancements

 * Very bugs :bug:
 * No way to configure port number text colour
 * Label text is sometimes truncated when using a vertical layout
 * It should be possible to render units vertically with label text on the right (e.g. for PDU layouts)
 * The templates should contain more examples of configuration values and pick up on configuration values set in the asset mutable data
 * There are no options for groups of ports/different port types/spacings

# Contributing

Fork the project. Make your feature addition or bug fix. Send a pull
request. Bonus points for topic branches.

# License

Eclipse Public License 2.0, see [LICENSE.txt](LICENSE.txt) for details.

Copyright (C) 2019-present Alces Flight Ltd.

This program and the accompanying materials are made available under
the terms of the Eclipse Public License 2.0 which is available at
[https://www.eclipse.org/legal/epl-2.0](https://www.eclipse.org/legal/epl-2.0),
or alternative license terms made available by Alces Flight Ltd -
please direct inquiries about licensing to
[licensing@alces-software.com.

Flight Inventory Diagrams is distributed in the hope that it will be
useful, but WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER
EXPRESS OR IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR
CONDITIONS OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR
A PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
details.
