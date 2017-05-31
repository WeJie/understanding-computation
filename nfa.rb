#! /usr/bin/env ruby

require 'set'
require './dfa'

class NFARulebook < Struct.new(:rules)
  def next_states(states, character)
    states.flat_map { |state| follow_rules_for(state, character) }.to_set
  end

  def follow_rules_for(state, character)
    rules_for(state, character).map(&:follow)
  end

  def rules_for(state, character)
    rules.select { |rule| rule.applies_to?(state, character) }
  end

  def follow_free_moves(states)
    more_states = next_states(states, nil)
    
    if more_states.subset?(states)
      states
    else
      follow_free_moves(states + more_states)
    end
  end

  def alphabet
    rules.map(&:character).compact.uniq
  end
end

rulebook = NFARulebook.new([
  FARule.new(1, 'a', 2), FARule.new(1, 'b', 1), FARule.new(1, 'b', 2),
  FARule.new(2, 'a', 2), FARule.new(2, 'b', 3),
  FARule.new(3, 'a', 3), FARule.new(3, 'b', 3)
])

print rulebook.next_states(Set[1], 'a'), "\n"
print rulebook.next_states(Set[1, 2], 'b'), "\n"
print rulebook.next_states(Set[1, 3], 'b'), "\n"
print rulebook.follow_free_moves(Set[1]), "\n"

class NFA < Struct.new(:current_states, :accept_states, :rulebook)
  def current_states
    rulebook.follow_free_moves(super)
  end

  def accepting?
    (current_states & accept_states).any?
  end

  def read_character(character)
    self.current_states = rulebook.next_states(current_states, character)
  end

  def read_string(string)
    string.chars.each do |character|
      read_character(character)
    end
  end
end

print NFA.new(Set[1], [4], rulebook).accepting?
print NFA.new(Set[1, 2, 4], [4], rulebook).accepting?

class NFADesign < Struct.new(:start_state, :accept_states, :rulebook)
  def to_nfa(current_states = Set[start_state])
    NFA.new(current_states, accept_states, rulebook)
  end

  def accepts?(string)
    # tap 对代码块求值，然后返回调用它的对象`
    to_nfa.tap { |nfa| nfa.read_string(string) }.accepting?
  end
end 

class NFASimulation < Struct.new(:nfa_design)
  def next_state(state, character)
    nfa_design.to_nfa(state).tap {
      |nfa|
      nfa.read_character(character)
    }.current_states
  end

  def rules_for(state)
    nfa_design.rulebook.alphabet.map {
      |character|
      FARule.new(state, character, next_state(state, character))
    }
  end

  def discover_states_and_rules(states)
    rules = states.flat_map { |state| rules_for(state) }
    more_states = rules.map(&:follow).to_set

    if more_states.subset?(states)
      [states, rules]
    else
      discover_states_and_rules(states + more_states)
    end
  end

  def to_dfa_design
    start_state = nfa_design.to_nfa.current_states
    states, rules = discover_states_and_rules(Set[start_state])
    accept_states = states.select { |state| nfa_design.to_nfa(state).accepting? }

    DFADesign.new(start_state, accept_states, DFARulebook.new(rules))
  end
end

nfa_design = NFADesign.new(1, [3], rulebook)
simulation = NFASimulation.new(nfa_design)
dfa_design = simulation.to_dfa_design
dfa_design.accepts?('aaa')

require 'treetop'
Treetop.load 'nfa-grammar'
print parse_tree = PatternParser.new.parse('(a(|b))*')
