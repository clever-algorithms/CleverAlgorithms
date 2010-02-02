# Guided Local Search in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

# TODO TODO TODO

NUM_ITERATIONS = 100
PROBLEM_SIZE = 2
SEARCH_SPACE = Array.new(PROBLEM_SIZE) {|i| [-5, +5]}

def cost(candidate_vector)
  return candidate_vector.inject(0) {|sum, x| sum +  (x ** 2.0)}
end

def random_solution(problemSize, searchSpace)
  return Array.new(problemSize) do |i|      
    searchSpace[i][0] + ((searchSpace[i][1] - searchSpace[i][0]) * rand)
  end
end

def search(numIterations, problemSize, searchSpace)
  best = nil
  numIterations.times do |iter|
    candidate = {}
    candidate[:vector] = random_solution(problemSize, searchSpace)
    candidate[:cost] = cost(candidate[:vector])
    best = candidate if best.nil? or candidate[:cost] < best[:cost]
    puts " > iteration #{(iter+1)}, best: c=#{best[:cost]}, v=#{best[:vector].inspect}"
  end
  return best
end

best = search(NUM_ITERATIONS, PROBLEM_SIZE, SEARCH_SPACE)
puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"