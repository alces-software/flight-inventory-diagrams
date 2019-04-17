#!/usr/bin/env ruby
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
$: << File.join(File.dirname(__FILE__),'..','lib')

require 'ostruct'
require 'erb'

class NodeData
  attr_accessor :name, :mutable
  def initialize(mutable_vals)
    @mutable = OpenStruct.new(mutable_vals)
    @name = "example"
  end
end

class Template
  TEMPLATE_DIR = File.join(File.dirname(__FILE__),'..','templates')
  HELPER_DIR = File.join(File.dirname(__FILE__),'..','helpers')

  def initialize(name)
    @template = File.read(File.join(TEMPLATE_DIR, "#{name}.erb"))
  end

  def render(asset_data)
    env = render_env(asset_data)
    env.instance_variable_set(:@asset_data, asset_data)
    ctx = env.instance_eval { binding }
    ERB.new(@template, nil, '-').result(ctx)
  end

  def render_env(asset_data)
    @render_env ||=
      begin
        Module.new do
          class << self
            attr_reader :asset_data
          end
        end.tap do |m|
          Dir[File.join(HELPER_DIR,'*.rb')].each do |file|
            m.instance_eval(File.read(file), file)
          end
        end
      end
  end
end

LAYOUTS = [
  {
    width: 24,
    height: 2,
    layout: 't-l-h',
    map_type: :simple,
  },
  {
    width: 10,
    height: 4,
    layout: 't-l-v',
    map_type: :bmc,
  },
  {
    width: 12,
    height: 2,
    layout: 'b-r-h',
    map_type: :simple,
  },
  {
    width: 16,
    height: 3,
    layout: 't-r-v',
    map_type: :bmc,
  }
]

def create_simple_map(w, h)
  {}.tap do |map|
    (1..(w*h)).map do |n|
      map[n] = sprintf("node%02d",n)
    end
  end
end

def create_bmc_map(w, h)
  {}.tap do |map|
    (1..(w*h)).map do |i|
      if i > (w*h)/2
        n = i - (w*h)/2
        map[i] = sprintf("node%02d:bmc",n)
      else
        map[i] = sprintf("node%02d",i)
      end
    end
  end
end

markdown_tpl = Template.new('switch.md')
svg_tpl = Template.new('switch.svg')

LAYOUTS.each do |l|
  asset_data = NodeData.new(
    {
      map: send("create_#{l[:map_type]}_map", l[:width], l[:height]),
      width: l[:width].to_s,
      height: l[:height].to_s,
      layout: l[:layout],
    }
  )
  title = "#{l[:width]}x#{l[:height]}-#{l[:layout]}-#{l[:map_type]}"
  svg_out = svg_tpl.render(asset_data)
  File.open("#{title}.svg",'w') { |f| f.puts(svg_out) }
  md_out = markdown_tpl.render(asset_data)
  File.open("#{title}.md",'w') { |f| f.puts(md_out) }
end
