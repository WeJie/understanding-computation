#! /usr/bin/env ruby

require 'rubygems'
require 'treetop'
Treetop.load 'formal-semantic'

print parse_tree = SimpleParser.new.parse('while (x < 5) { x = x * 3 }')
