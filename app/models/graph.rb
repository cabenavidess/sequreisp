# Sequreisp - Copyright 2010, 2011 Luciano Ruete
#
# This file is part of Sequreisp.
#
# Sequreisp is free software: you can redistribute it and/or modify
# it under the terms of the GNU Afero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Sequreisp is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Afero General Public License for more details.
#
# You should have received a copy of the GNU Afero General Public License
# along with Sequreisp.  If not, see <http://www.gnu.org/licenses/>.

class Graph
  GREEN = '#00aa00'
  RED = '#aa0000'
  BLUE = '#0000aa'
  VIOLET = '#8000ff'

  attr_accessor :model, :method, :render, :height, :width, :float

  def initialize(model, method, options={})
    @model = model
    @method = method
    @render = "#{@model.class.name.underscore}_#{@model.id}_#{@method}"
    @minimal = false
  end

  def graph!
    gra = send(@method).to_json
    gra.scan(/\"function.*\}\"/).flatten.each{|str| gra.sub!(str, str[1..-2]) }
    gra
  end

  def minimal_graph
    @minimal = true
    _graph = graph!
    @minimal = false
    _graph
  end

  def hash_graph
    JSON.parse(graph!)
  end

  def name; @model.class.name; end

  def self.all_graphs(model)
    model_graph = "#{model.class.name}Graph".constantize
    model_graph::GRAPHS.map{|g| model_graph.new(model, g)}
  end

  def path
    "graph_#{@model.class.name.downcase}_path(#{@model.id})"
    #eval("app.graph_#{@model.class.name.downcase}_path(#{@model.id})") # ESTE SIRVE PARA CUANDO LO EJECUTO DESDE CONSOLA
  end

  def self.credit_text
    SOFT_NAME
  end

  def self.credit_href
    SOFT_URL
  end

  private

  def default_options_graphs options={}
    options[:type] ||= 'line'
    options[:xtype] ||= 'datetime'
    options[:tooltip_formatter] ||= ''
    options[:zoomType] ||= 'x'
    options[:navigator] ||= 'false'

    { :credits       => { :enabled => @minimal? false : true,
                          :text => Graph.credit_text,
                          :href => Graph.credit_href },
      :rangeSelector => { :enabled => false },
      :chart         => { :renderTo => @render,
                          :zoomType => @minimal? "" : options[:zoomType],
                          :type => options[:type] },
      :tooltip       => { :formatter => options[:tooltip_formatter] },
      :exporting     => { :enabled => @minimal? false : true },
      :legend        => { :enabled => @minimal? false : true,
                          :verticalAlign => 'bottom' },
      :title         => { :text => @minimal? '' : options[:title] },
      :xAxis         => { :type => options[:xtype] },
      :yAxis         => { :title => { :text => @minimal? '' : options[:ytitle] } },
      :plotOptions   => { options[:type].to_sym => { :stacking => options[:stacking] } },
      :series        => options[:series],
      :colors        => [GREEN, RED, BLUE, VIOLET],
      :scrollbar     => { :enabled => false },
      :navigator     => { :enabled => options[:navigator] }
    }
  end

  def faker_values hash=nil
    hash ||= { :keys => {}, :size => 0 }
    fake = {}
    date_time_now = (DateTime.now.to_i + Time.now.utc_offset) * 1000

    hash[:keys].each do |key, value|
      fake[key] = []
      hash[:size].times do |i|
        date = date_time_now - (i * 5000)
        fake[key] << [ date, value.zero? ? 0 : rand(value) ]
      end
    end

    fake.each_key { |key| fake[key].reverse! }

    fake
  end

  def add_empty_values(hash)
    unless hash[:data].size >= hash[:size]
      first_time = hash[:data].empty? ? ((DateTime.now.to_i + Time.now.utc_offset) * 1000) : hash[:data].sort.first[0]
      1.upto(hash[:size] - hash[:data].size) do |i|
        hash[:data] << [(first_time - (i * 5000)), 0]
      end
    end
    hash[:data].sort
  end

end
