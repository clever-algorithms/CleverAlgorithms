# Adaptive Random Search in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

NUM_ITERATIONS = 1000
PROBLEM_SIZE = 2
SEARCH_SPACE = Array.new(PROBLEM_SIZE) {|i| [-5, +5]}
INITIAL_STEP_SIZE_FACTOR = 0.05
STEP_FACTOR_SMALL = 1.3
STEP_FACTOR_LARGE = 3
STEP_FACTOR_LARGE_MULTIPLE = 10
MAX_NO_IMPROVEMENTS = 30

def cost(candidate_vector)
  return candidate_vector.inject(0) {|sum, x| sum +  (x ** 2.0)}
end

def random_solution(problemSize, searchSpace)
  return Array.new(problemSize) do |i|      
    searchSpace[i][0] + ((searchSpace[i][1] - searchSpace[i][0]) * rand)
  end
end

def take_step(problemSize, searchSpace, currentPosition, stepSize)
  step = []
  problemSize.times do |i|
    max, min = currentPosition[i]+stepSize, currentPosition[i]-stepSize
    max = searchSpace[i][1] if max > searchSpace[i][1]
    min = searchSpace[i][0] if min < searchSpace[i][0]
    step << min + ((max - min) * rand)
  end
  return step
end

def search(numIterations, problemSize, searchSpace)
  stepSize = (searchSpace[0][1]-searchSpace[0][0]) * INITIAL_STEP_SIZE_FACTOR
  current, count = {}, 0
  current[:vector] = random_solution(problemSize, searchSpace)
  current[:cost] = cost(current[:vector])
  numIterations.times do |iter|
    step, biggerStep = {}, {}
    step[:vector] = take_step(problemSize, searchSpace, current[:vector], stepSize)
    step[:cost] = cost(step[:vector])
    biggerStepSize = stepSize * STEP_FACTOR_SMALL
    biggerStepSize = stepSize * STEP_FACTOR_LARGE if iter.modulo(STEP_FACTOR_LARGE_MULTIPLE)
    biggerStep[:vector] = take_step(problemSize, searchSpace, current[:vector], biggerStepSize)
    biggerStep[:cost] = cost(biggerStep[:vector])    
    if step[:cost] <= current[:cost] or biggerStep[:cost] <= current[:cost]
      if biggerStep[:cost] < step[:cost]
        stepSize, current = biggerStepSize, biggerStep
      else
        current = step
      end
      count = 0
    else
      count += 1
      count, stepSize = 0, (stepSize/STEP_FACTOR_SMALL) if count >= MAX_NO_IMPROVEMENTS
    end
    puts " > iter #{(iter+1)}, cost=#{current[:cost]}, v=#{current[:vector].inspect}"
  end
  return current
end

best = search(NUM_ITERATIONS, PROBLEM_SIZE, SEARCH_SPACE)
puts "Done. Best Solution: cost=#{best[:cost]}, v=#{best[:vector].inspect}"