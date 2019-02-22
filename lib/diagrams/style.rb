#==============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Flight Inventory Diagrams.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
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
module Diagrams
  class Style
    attr_accessor :port_width, :port_height, :padding
    attr_accessor :margin, :radius, :unit_colour
    attr_accessor :bg_colour, :port_colour
    attr_accessor :port_font_size, :name_font_size
    attr_accessor :name_pad_factor, :name_colour
    attr_accessor :name_colours
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
  end
end
