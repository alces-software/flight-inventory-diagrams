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
$: << File.join(__FILE__,'..','..','lib')
require 'base64'
require 'victor'
require 'diagrams'

def render_switch(opts)
  map = @node_data.mutable.map&.to_h
  return "" if map.nil?
  opts = Diagrams::Options.new(opts, map)

  names = []
  map.each do |k,v|
    name, type = v.split(':')
    name = name.length > opts.truncate_at ? name[0..opts.truncate_at] + "…" : name
    names[k-1] = [name, type].join(':')
  end

  layout = Diagrams::Layout.new(opts)
  Diagrams::Style.new(opts.style_opts).render(layout, names).render
end

def render_switch_base64(*args)
  Base64.strict_encode64(render_switch(*args))
end
