#! /usr/bin/env ruby

class Number < Struct.new(:value)
	def to_ruby
		"-> e { e[#{name.inspect}] }"
  end

	def inspect
		"《#{self}》"
	end
end

class Boolean < Struct.new(:value)
	def to_ruby
		"-> e { #{value.inspect} }"
  end

	def to_s
		value.to_s
	end

	def inspect
		"《#{self}》"
	end
end

class Variable < Struct.new(:name)
	def to_ruby
		"-> e { e[#{name.inspect}] }"
  end

	def to_s
		name.to_s
	end

	def inspect
		"《#{self}》"
	end
end

class Add < Struct.new(:left, :right)
	def to_ruby
		":-> e { (#{left.to_ruby}).call(e) + (#{right.to_ruby}.call(e)) }"
  end

	def to_s
		"#{left} + #{right}"
	end
	
	def inspect
		"《#{self}》"
	end
end

class Multiply < Struct.new(:left, :right)
	def to_ruby
		"-> e { (#{left.to_ruby}).call(e) * (#{right.to_ruby}).call(e) }"
	end

	def to_s
		"#{left} * #{right}"
	end
	
	def inspect
		"《#{self}》"
	end
end

class LessThan < Struct.new(:left, :right)
	def to_ruby
		"-> e { (#{left.to_ruby}).call(e) < (#{right.to_ruby}).call(e) }"
	end

	def to_s
		"《#{left} < #{right}》"
	end

	def inspect
		"《#{self}》"
	end
end

class Assign < Struct.new(:name, :expression)
	def to_ruby
		"-> e { e.merge({ #{name.inspect} => {#{expersion.to_ruby}}.call(e) }) }"
  end

	def to_s
		"#{name} = #{expression}"
	end

	def inspect
		"《#{self}》"
	end
end

class DoNothing
	def to_ruby
		"e -> { e }"
  end 

	def to_s
		'do-nothing'
	end

	def inspect
		"《#{self}》"
	end

	def ==(other_statement)
		other_statement.instance_of?(DoNothing)
	end
end

class If < Struct.new(:condition, :consequence, :alternative)
	def to_ruby
		"-> e { if (#{condintion.to_ruby}).call(e)" +
		  " then (#{consequence.to_ruby}).call(e)" +
		  " else (#{alternative.to_ruby}).call(e)" +
		  " end }"
  end

	def to_s
		"if (#{condition}) { #{consequence} } else { #{alternative} }"
	end

	def inspect
		"《#{self}》"
	end
end

class Sequence < Struct.new(:first, :second)
	def to_ruby
		"-> e { (#{second.to_ruby}).call((#{first.to_ruby}).calle(e)) }"
  end 

	def to_s
		"#{first}; #{second}"
	end

	def inspect
		"《#{self}》"
	end
end

class While < Struct.new(:condition, :body)
	def to_ruby
		"-> e {" +
		" while (#{condition.to_ruby}).call(e); e = (#{body.to_ruby}).call(e); end;" +
		" e" +
		" }"
  end

	def to_s
		"while (#{condition}) { #{body} }"
	end

	def inspect
		"《#{self}》"
	end
end

statement = While.new(
	LessThan.new(Variable.new(:x), Number.new(5)),
	Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))
)

print statement