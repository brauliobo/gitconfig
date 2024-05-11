#!/usr/bin/env ruby

require_relative 'base.rb'

SC_LIST.each do |s|
  toggle s, ARGV[0]
end

