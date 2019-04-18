# coding: utf-8
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
require 'ostruct'
require 'diagrams/drawing'
require 'diagrams/layout'
require 'diagrams/style'

module Diagrams
  class Renderer
    class << self
      def render(opts, map)
        template = opts.fetch(:embed, false) ? :html : :default
        new(opts, map).render(template)
      end
    end

    def initialize(opts, map)
      truncate_at = opts.fetch(:truncate_at, 15)
      @style = create_style(opts)
      @names = create_name_array(map, truncate_at)
      @layout = create_layout(opts)
    end

    def render(template = :default)
      Diagrams::Drawing.draw(
        @style,
        @layout,
        @names,
        template
      ).render
    end

    private
    def create_style(opts)
      style_opts = {
        name_colours: {
          switch: :green,
          bmc: :purple
        }
      }.merge(opts.fetch(:style, {}))
      Diagrams::Style.new(style_opts)
    end

    def create_layout(opts)
      dimensions = dimensions_from(opts)
      layout = layout_from(opts)
      first_port = opts.fetch(:first_port, 1)

      Diagrams::Layout.new(
        dimensions.width,
        dimensions.height,
        *layout,
        first_port
      )
    end

    def create_name_array(map, truncate_at)
      [].tap do |names|
        (map || {}).each do |k,v|
          names[k-1] = truncated_name(v, truncate_at)
        end
      end
    end

    def truncated_name(name, truncate_at)
      name, type = name.split(':')
      [
        (name.length > truncate_at ? name[0..truncate_at] + "…" : name),
        type
      ].join(':')
    end

    def dimensions_from(opts)
      if opts[:width] || opts[:height]
        w = (Integer(opts[:width]) rescue nil)
        h = (Integer(opts[:height]) rescue 1)
      elsif opts[:ports]
        h = (Integer(opts[:rows]) rescue 1)
        w = ((Integer(opts[:ports]) / h + 1) rescue nil)
      end

      if w.nil?
        w = @names.length
        if w > 16
          h = (w / 16) + 1
          w = 16
        else
          h = 1
        end
      end
      OpenStruct.new(width: w, height: h)
    end

    def layout_from(opts)
      layout_descriptor = opts.fetch(:layout) || 't-l-h'
      layout_descriptor.split('-').map do |e|
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
          raise "Unrecognized layout atom: #{e} (#{layout_descriptor})"
        end
      end
    end
  end
end
