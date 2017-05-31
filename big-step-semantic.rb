#! /usr/bin/env ruby

class Number < Struct.new(:value)
	def evaluate(environment)
		self
	end
end

class Add < Struct.new(:left, :right)
	def evaluate(environment)
		Number.new(left.evaluate(environment).value +  right.evaluate(environment).value)
	end
end

class Multiply < Struct.new(:left, :right)
	def evaluate(environment)
		Number.new(left.evaluate(environment).value * right.evaluate(environment).value)
	end
end

class Boolean < Struct.new(:value)
	def evaluate(environment)
		self
	end
end

class LessThan < Struct.new(:left, :right)
	def evaluate(environment)
		Boolean.new(left.evaluate(environment).value > right.evaluate(environment).value)
	end
end

class Variable < Struct.new(:name)
	def evaluate(environment)
		environment[name]
	end
end

class Assign < Struct.new(:name, :expression)
	def evaluate(environment)
		environment.merge({ name => expression.evaluate(environment) })
	end
end

class DoNothing
	def evaluate(environment)
		environment
	end
end

class If < Struct.new(:condition, :consequence, :alternative)
	def evaluate(environment)
		case condition.evaaluate(environment)
		when Boolean.new(true)
			consequence.evaluate(environment)
		when Boolean.new(false)
			alternative.evaluate(environment)
		end
	end
end

class Sequence < Struct.new(:first, :second)
	def evaluate(environment)
		second.evaluate(first.evaluate(environment))
	end
end

class While < Struct.new(:condition, :body)
	def evaluate(environment)
		case condition.evaluate(environment)
		when Boolean.new(true)
			evaluate(body.evaluate(environment))
		when Boolean.new(false)
			environment
		end
  end
end

statement = While.new(
	LessThan.new(Variable.new(:x), Number.new(5)),
	Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))
)
print statement.evaluate({ x: Number.new(1) })

