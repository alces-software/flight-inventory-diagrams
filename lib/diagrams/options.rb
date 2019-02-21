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
  class Options
    attr_accessor :width, :height, :layout, :truncate_at, :style_opts, :first_num

    def initialize(opts, map)
      @width = (Integer(opts[:width]) || nil) rescue nil
      @height = (Integer(opts.fetch(:height)) || 1) rescue nil
      @truncate_at = opts.fetch(:truncate_at, 9)

      if @width.nil?
        @width = map.keys.max
        if @width > 16
          @height = (@width / 16) + 1
          @width = 16
        end
      end

      layout = opts.fetch(:layout) || 't-l-h'
      @layout = layout.split('-').map do |e|
        case e
        when 't'
          :top
        when 'b'
          :bottom
        when 'l'
          :left
        when 'r'
          :right
        when 'h'
          :horizontal
        when 'v'
          :vertical
        else
          raise "Unrecognized layout atom: #{e} (#{port_layout})"
        end
      end

      @style_opts = {
        name_colours: {switch: :green, bmc: :purple}
      }.merge(opts.fetch(:style, {}))

      @first_num = opts.fetch(:first_num, 1)
    end
  end
end
