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
module Diagrams
  class Style
    attr_accessor :port_width, :port_height, :padding
    attr_accessor :margin, :radius, :unit_colour
    attr_accessor :bg_colour, :port_colour
    def initialize(opts = {})
      @port_width = opts.fetch(:port_width, 50)
      @port_height = opts.fetch(:port_height, 50)
      @padding = opts.fetch(:padding, 5)
      @margin = opts.fetch(:margin, 10)
      @radius = opts.fetch(:radius, 10)
      @unit_colour = opts.fetch(:unit_colour, '#666')
      @bg_colour = opts.fetch(:bg_colour, '#ddd')
      @port_colour = opts.fetch(:port_colour, '#000')
      @port_font_size = opts.fetch(:port_font_size, 30)
      @name_font_size = opts.fetch(:name_font_size, 25)
      @name_pad_factor = opts.fetch(:name_pad_factor, (@name_font_size/16.0)*10)
      @name_colour = opts.fetch(:name_colour, '#5588cc')
      @template = opts.fetch(:embed, false) ? :html : :default
      @name_colours = {
        default: @name_colour
      }.merge(opts.fetch(:name_colours, {}))
    end

    def port_width_with_padding
      @width_with_padding ||=
        @port_width + @padding
    end

    def unit_height
      @unit_height ||= @port_height + (@padding * 2)
    end

    def max_name_length(names)
      names.max do |a,b|
        a.split(':').first.length <=> b.split(':').first.length
      end.split(':').first.length rescue 0
    end

    def row_height_for(names)
      max_len = max_name_length(names.compact)
      (max_len * @name_pad_factor) + unit_height
    end

    def padding_right_for(names, height, width)
      last_names = (0..(height-1)).map do |row|
        names[(row*width + width) - 1]
      end
      max_len = max_name_length(last_names.compact)
      [(max_len * @name_pad_factor) - @port_width, 0].max
    end

    def render_unit(svg, row_pos, num_ports)
      unit_width = (port_width_with_padding * num_ports) + @padding
      svg.rect(
        x: @margin,
        y: @margin + row_pos,
        width: unit_width,
        height: unit_height,
        rx: @radius,
        fill: @unit_colour
      )
    end

    def render_port(svg, row_pos, port_pos, port_num)
      svg.rect(
        x: @margin + @padding + port_pos,
        y: @margin + @padding + row_pos,
        width: @port_width,
        height: @port_height,
        rx: @radius,
        fill: @port_colour
      )
      svg.text(
        port_num.to_s,
        text_anchor: :middle,
        x: @margin + @padding + (@port_width/2) + port_pos,
        y: @margin + @padding + (@port_height/2) + (@port_font_size/3) + row_pos,
        font_size: @port_font_size,
        fill: :white,
        font_family: 'times'
      )
    end

    def render_label(svg, row_pos, port_pos, label)
      x = @margin + @padding + port_pos
      y = @margin + unit_height + @padding + row_pos + (@name_font_size/2)
      text, type = label.split(':')
      type = type&.to_sym
      colour =
        case type
        when Symbol
          @name_colours.fetch(type, :black)
        else
          @name_colours.fetch(:default, :black)
        end
      svg.text(
        text,
        text_anchor: :left,
        x: x,
        y: y,
        font_size: @name_font_size,
        fill: colour,
        font_family: 'arial black',
        transform: "translate(#{@port_width / 4} 0) rotate(45 #{x} #{y})"
      )
    end

    def create_canvas(num_ports, num_rows, row_height, padding_right)
      w = (port_width_with_padding * num_ports) + (@margin * 2) + @padding + padding_right
      h = (row_height * num_rows) + (@margin * 2)
      Victor::SVG.new(
        width: w,
        height: h,
        style: { background: '#fff' },
        template: @template,
      ).tap do |svg|
        svg.rect(
          x: 0,
          y: 0,
          width: w,
          height: h,
          fill: @bg_colour
        )
      end
    end

    def render(layout, names)
      row_height = row_height_for(names)
      padding_right = padding_right_for(names, layout.height, layout.width)
      create_canvas(layout.width, layout.height, row_height, padding_right).tap do |svg|
        (0..(layout.height - 1)).each do |row|
          row_pos = row * row_height
          render_unit(svg, row_pos, layout.width)
          (0..(layout.width-1)).each do |port|
            port_pos = port * port_width_with_padding
            port_num = layout.port_number_for(port, row)
            port_label = layout.port_label_for(port_num)
            render_port(svg, row_pos, port_pos, port_label)
            if label = names[port_num]
              render_label(svg, row_pos, port_pos, label)
            end
          end
        end
      end
    end
  end
end
