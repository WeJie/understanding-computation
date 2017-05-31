#! /usr/bin/env ruby

class FARule < Struct.new(:state, :character, :next_state)
  def applies_to?(state, character)
    self.state == state && self.character == character
  end

  def follow
    next_state
  end

  def inspect
    "#<FARule #{state.inspect} --#{character}--> #{next_state.inspect}>"
  end
end

class DFARulebook < Struct.new(:rules)
  def next_state(state, character)
    rule_for(state, character).follow
  end

  def rule_for(state, character)
    rules.detect { |rule| rule.applies_to?(state, character) }
  end
end

rulebook = DFARulebook.new([
  FARule.new(1, 'a', 2), FARule.new(1, 'b', 1),
  FARule.new(2, 'a', 2), FARule.new(2, 'b', 3),
  FARule.new(3, 'a', 3), FARule.new(3, 'b', 3)
])

# print rulebook.next_state(1, 'a')
# print rulebook.next_state(1, 'b')
# print rulebook.next_state(2, 'b')

class DFA < Struct.new(:current_state, :accept_states, :rulebook)
  def accepting?
    accept_states.include?(current_state)
  end

  def read_character(character)
    self.current_state = rulebook.next_state(current_state, character)
  end

  def read_string(string)
    string.chars.each do |character|
      read_character(character)
    end
  end
end

print DFA.new(1, [1, 3], rulebook).accepting?
print DFA.new(1, [1, 3], rulebook).accepting?

class DFADesign < Struct.new(:start_state, :accept_states, :rulebook)
  def to_dfa
    DFA.new(start_state, accept_states, rulebook)
  end

  def accepts?(string)
    # tap 对代码块求值，然后返回调用它的对象`
    to_dfa.tap { |dfa| dfa.read_string(string) }.accepting?
  end
end 

dfa_design = DFADesign.new(1, [3], rulebook)
# print dfa_design.accepts?('a')
# print dfa_design.accepts?('baa')
# print dfa_design.accepts?('baba')
