# Stochastic Hill Climbing algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

NUM_ITERATIONS = 1000
PROBLEM_SIZE = 64

def cost(bitstring)
  return bitstring.inject(0) {|sum,x| sum = sum + ((x=='1') ? 1 : 0)}
end

def random_solution(problemSize)
  return Array.new(problemSize){|i| (rand<0.5) ? "1" : "0"}
end

def take_step(bitstring)  
  mutant = Array.new(bitstring)
  pos = rand(bitstring.length)
  mutant[pos] = (mutant[pos]=='1') ? '0' : '1'
  return mutant
end

def search(numIterations, problemSize)
  candidate = {}
  candidate[:vector] = random_solution(problemSize)
  candidate[:cost] = cost(candidate[:vector])
  numIterations.times do |iter|
    mutant = {}
    mutant[:vector] = take_step(candidate[:vector])
    mutant[:cost] = cost(mutant[:vector])
    candidate = mutant if mutant[:cost] > candidate[:cost]
    puts " > iteration #{(iter+1)}, best: c=#{candidate[:cost]}, v=#{candidate[:vector].join}"
    break if candidate[:cost] == problemSize
  end 
  return candidate
end

best = search(NUM_ITERATIONS, PROBLEM_SIZE)
puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].join}"