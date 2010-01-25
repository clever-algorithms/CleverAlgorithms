# Random Search in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

NUM_ITERATIONS = 100
PROBLEM_SIZE = 2
SEARCH_SPACE = Array.new(PROBLEM_SIZE) {|i| [-5, +5]}

def cost_function(candidate_vector)
  return candidate_vector.inject(0) {|sum, x| sum +  (x ** 2.0)}
end

def random_float(min, max)
  min + ((max - min) * rand)
end

def search
  best = nil
  NUM_ITERATIONS.times do |iter|
    candidate = {}
    candidate[:vector] = Array.new(PROBLEM_SIZE) do |i|      
      random_float(SEARCH_SPACE[i][0], SEARCH_SPACE[i][1])
    end
    candidate[:cost] = cost_function(candidate[:vector])
    best = candidate if best.nil? or candidate[:cost] < best[:cost]
    puts " > iteration #{iter} c=#{best[:cost]}, v=#{best[:vector].inspect}"
  end
  return best
end

best = search
puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"