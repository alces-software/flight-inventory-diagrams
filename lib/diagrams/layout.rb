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
module Diagrams
  class Layout
    attr_accessor :width, :height, :direction, :origin_row, :origin_col, :first
    def initialize(opts)
      #width, height, origin_row, origin_col, direction, first = 1)
      @width = opts.width
      @height = opts.height
      @origin_row = opts.layout[0]
      @origin_col = opts.layout[1]
      @direction = opts.layout[2]
      @first = opts.first_num
    end

    def port_label_for(num)
      num + first
    end

    def port_number_for(x, y)
      row = case origin_row
            when :top
              # 1 2 3
              # 4 5 6
              y
            when :bottom
              # 4 5 6
              # 1 2 3
              height - y - 1
            else
              raise "Unknown vertical origin: #{origin_row}"
            end
      col = case origin_col
            when :left
              # 1 2 3
              # 4 5 6
              x
            when :right
              # 3 2 1
              # 6 5 4
              width - x - 1
            else
              raise "Unknown horizontal origin: #{origin_col}"
            end
      case direction
      when :horizontal
        # 1 2 3
        # 4 5 6
        (row * width) + col
      when :vertical
        # 1 3 5
        # 2 4 6
        row + (col * height)
      else
        raise "Unknown direction: #{direction}"
      end
    end
  end
end
