# Inspired Algorithms, http://InspiredAlgorithms.com
# Copyright (C) 2009  Jason Brownlee
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# Localized Random Search


class OneMaxFunction
  attr_reader :length

  def initialize(length=16)
    @length = length
  end

  def evaluate(bitstring)
    bitstring.inject(0) {|sum, x| sum + ((x=='1') ? 1 : 0)}
  end  

  def is_optimal?(scoring)
    scoring == optimal_score
  end

  def optimal_score
    @length
  end
  
  # true if s1 has the same or better score than s2
  def is_same_or_better?(s1, s2)
    s1 >= s2 # maximizing
  end
end

class Solution
  attr_reader :data
  attr_accessor :score
  
  def initialize(data)
    @data = data
    @score = 0.0/0.0 # NaN
  end
  
  def to_s
    "[#{@data.collect{|x|x}}] (#{@score})"
  end    
end

class LocalizedRandomSearchAlgorithm
  attr_accessor :max_iterations
  attr_reader :best_solution
  
  def initialize(max_iterations)
    @max_iterations = max_iterations
  end
  
  # execute a localized random search on the provided problem
  def search(problem)
    @best_solution = generate_random_solution(problem) # starting point
    @best_solution.score = problem.evaluate(@best_solution.data)
    curr_it = 0
    begin
      # generate mutant
      candidate = generate_mutate_solution(@best_solution)
      candidate.score = problem.evaluate(candidate.data)
      # compare to current best
      if problem.is_same_or_better?(candidate.score, @best_solution.score)
        @best_solution = candidate
        puts " > new best: #{@best_solution.score}"    
      end
      curr_it += 1
    end until should_stop?(curr_it, problem)
    return @best_solution
  end
  
  def should_stop?(curr_it, problem)
    (curr_it >= @max_iterations) or problem.is_optimal?(best_solution.score)
  end
  
  def generate_random_solution(problem)
    bitstring = Array.new(problem.length) {|i| (rand<0.5) ? "1" : "0"}
    return Solution.new(bitstring)
  end

  def generate_mutate_solution(solution)
    data = solution.data
    bitstring = Array.new(data.length) do |i| 
      if should_mutate?(data.length)
         (data[i]=='0') ? "1" : "0" # invert
      else
        data[i]
      end
    end
    return Solution.new(bitstring)
  end
  
  def should_mutate?(length)
    rand < 1.0/length
  end
end

srand(1) # set the random number seed to 1
algorithm = LocalizedRandomSearchAlgorithm.new(1000) # limit to 1000 iterations 
problem = OneMaxFunction.new(32) # create a problem with 32 bits
best = algorithm.search(problem) # execute the search
puts "Best Solution: #{best}" # display the best solution
