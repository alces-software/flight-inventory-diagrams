#==============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Flight Inventory Diagrams.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-software.com.
#
# Flight Inventory Diagrams is distributed in the hope that it will be
# useful, but WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER
# EXPRESS OR IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR
# CONDITIONS OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS
# FOR A PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for
# more details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Inventory Diagrams. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Inventory Diagrams, please visit:
# https://github.com/alces-software/flight-inventory-diagrams
#===============================================================================
# for a switch
# one rectangle outer
# multiple rectangles inner to represent ports
# text attached to each port
require 'victor'

module Diagrams
  class Drawing
    class << self
      def draw(style, layout, names, template = :default)
        new(
          style,
          layout,
          names,
          template
        ).draw
      end
    end

    def initialize(style, layout, names, template = :default)
      @style = style
      @layout = layout
      @names = names
      @template = template
    end

    def canvas
      @canvas ||=
        begin
          padding_right = padding_right_for(@names, @layout.height, @layout.width)
          w = (port_width_with_padding * @layout.width) + (margin * 2) + padding + padding_right
          h = (row_height * @layout.height) + (margin * 2)
          Victor::SVG.new(
            width: w,
            height: h,
            style: { background: '#fff' },
            template: @template,
          ).tap do |canvas|
            canvas.rect(
              x: 0,
              y: 0,
              width: w,
              height: h,
              fill: bg_colour
            )
          end
        end
    end

    def method_missing(s, *a, &b)
      if @style.respond_to?(s)
        @style.__send__(s, *a, &b)
      else
        super
      end
    end

    def respond_to_missing?(s)
      @style.respond_to?(s) || super
    end

    def row_height
      @row_height ||= row_height_for(@names)
    end

    def draw
      (0..(@layout.height - 1)).each do |row|
        draw_row(row)
      end
      canvas
    end

    def draw_row(row)
      unit_width = (port_width_with_padding * @layout.width) + padding
      canvas.rect(
        x: margin,
        y: margin + (row * row_height),
        width: unit_width,
        height: unit_height,
        rx: radius,
        fill: unit_colour
      )
      (0..(@layout.width-1)).each do |col|
        draw_port(row, col)
      end
    end

    def draw_port(row, col)
      y_pos = row * row_height
      x_pos = col * port_width_with_padding
      draw_socket(y_pos, x_pos)
      port_num = @layout.port_number_for(col, row)
      draw_socket_number(y_pos, x_pos, port_num)
      draw_label(y_pos, x_pos, port_num)
    end

    def draw_socket_number(y_pos, x_pos, port_num)
      canvas.text(
        @layout.port_label_for(port_num),
        text_anchor: :middle,
        x: margin + padding + (port_width/2) + x_pos,
        y: margin + padding + (port_height/2) + (port_font_size/3) + y_pos,
        font_size: port_font_size,
        fill: :white,
        font_family: 'times'
      )
    end

    def draw_socket(y_pos, x_pos)
      canvas.rect(
        x: margin + padding + x_pos,
        y: margin + padding + y_pos,
        width: port_width,
        height: port_height,
        rx: radius,
        fill: port_colour
      )
    end

    def draw_label(y_pos, x_pos, port_num)
      return unless label = @names[port_num]
      x = margin + padding + x_pos
      y = margin + unit_height + padding + y_pos + (name_font_size/2)
      text, type = label.split(':')
      type = type&.to_sym
      colour =
        case type
        when Symbol
          name_colours.fetch(type, :black)
        else
          name_colours.fetch(:default, :black)
        end
      canvas.text(
        text,
        text_anchor: :left,
        x: x,
        y: y,
        font_size: name_font_size,
        fill: colour,
        font_family: 'arial black',
        transform: "translate(#{port_width / 4} 0) rotate(45 #{x} #{y})"
      )
    end
  end
end
