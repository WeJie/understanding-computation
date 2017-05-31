#! /usr/bin/env ruby

require './lexical-analyzer'
require './npda'

start_rule = PDARule.new(1, nil, 2, '$', ['S', '$'])
symbol_rules = [
  PDARule.new(2, nil, 2, 'S', ['W']),
  PDARule.new(2, nil, 2, 'S', ['A']),

  PDARule.new(2, nil, 2, 'W', ['w', '(', 'E', ')', '{', 'S', '}']),

  PDARule.new(2, nil, 2, 'A', ['v', '=', 'E']),

  PDARule.new(2, nil, 2, 'E', ['L',]),

  PDARule.new(2, nil, 2, 'L', ['M', '<', 'L']),
  PDARule.new(2, nil, 2, 'L', ['M']),

  PDARule.new(2, nil, 2, 'M', ['T', '*', 'M']),
  PDARule.new(2, nil, 2, 'M', ['T']),

  PDARule.new(2, nil, 2, 'T', ['n']),
  PDARule.new(2, nil, 2, 'T', ['v']),
]

token_rules = LexicalAnalyzer::GRAMMAR.map do |rule|
  PDARule.new(2, rule[:token], 2, rule[:token], [])
end

stop_rule = PDARule.new(2, nil, 3, '$', ['$'])
rulebook = NPDARulebook.new([start_rule, stop_rule] + symbol_rules + token_rules)
npda_design = NPDADesign.new(1, '$', [3], rulebook)
token_string = LexicalAnalyzer.new('while (x < 5) { x = x * 3 }').analyze.join
print "answer: 5"
print npda_design.accepts?(token_string)
print npda_design.accepts?(LexicalAnalyzer.new('while (x < 5 x = x * }').analyze.join)