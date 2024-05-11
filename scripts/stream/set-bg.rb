#!/usr/bin/env ruby

require_relative 'base.rb'

BG      = ARGV[0]
SC_LIST.each do |s|
  show s, "bg_#{BG}"
  (BG_LIST - [BG]).each do |bg|
    hide s, "bg_#{bg}"
  end
end

