# Scatter Search algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

NUM_ITERATIONS = 100
PROBLEM_SIZE = 10
SEARCH_SPACE = Array.new(PROBLEM_SIZE) {|i| [-5, +5]}
STEP_SIZE = (SEARCH_SPACE[0][1]-SEARCH_SPACE[0][0])*0.05
LS_MAX_NO_IMPROVEMENTS = 50
DIVERSET_SET_SIZE = 10

def cost(candidate_vector)
  return candidate_vector.inject(0) {|sum, x| sum +  (x ** 2.0)}
end

def random_solution(problemSize, searchSpace)
  return Array.new(problemSize) do |i|      
    searchSpace[i][0] + ((searchSpace[i][1] - searchSpace[i][0]) * rand)
  end
end

def take_step(currentPosition, searchSpace, stepSize)
  step = []
  currentPosition.length.times do |i|
    max, min = currentPosition[i]+stepSize, currentPosition[i]-stepSize
    max = searchSpace[i][1] if max > searchSpace[i][1]
    min = searchSpace[i][0] if min < searchSpace[i][0]
    step << min + ((max - min) * rand)
  end
  return step
end

def local_search(best, searchSpace, maxNoImprovements, stepSize)
  noImprovements = 0
  begin
    candidate = {}
    candidate[:vector] = take_step(best[:vector], searchSpace, stepSize)    
    candidate[:cost] = cost(candidate[:vector])
    if candidate[:cost] < best[:cost]
      noImprovements, best = 0, candidate
    else
      noImprovements += 1      
    end
  end until noImprovements >= maxNoImprovements
  return best
end
  
def construct_reference_set(refSetSize, diversetSetSize, problemSize, searchSpace, maxNoImprovements, stepSize)
  referenceSet = []
  
  begin
    diverseSet = []
    diversetSetSize.times do |i|
      candidate = {}
      candidate[:vector] = random_solution(problemSize, searchSpace)
      candidate[:cost] = cost(candidate[:vector])
      candidate = local_search(candidate, searchSpace, maxNoImprovements, stepSize)
      if(!)
        diverseSet << candidate
      end
    end
    diverseSet.sort!{|x,y| x[:cost] <=> y[:cost]}
    
  end until referenceSet.length == refSetSize
  
  return referenceSet
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