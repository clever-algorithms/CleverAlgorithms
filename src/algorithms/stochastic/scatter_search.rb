# Scatter Search algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

NUM_ITERATIONS = 100
PROBLEM_SIZE = 3
SEARCH_SPACE = Array.new(PROBLEM_SIZE) {|i| [-5, +5]}
STEP_SIZE = (SEARCH_SPACE[0][1]-SEARCH_SPACE[0][0])*0.05
LS_MAX_NO_IMPROVEMENTS = 50
REF_SET_SIZE = 10
NO_ELITE = 5
MAX_SUBSET = 3

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

def construct_initial_reference_set(problemSize, searchSpace, refSetSize, maxNoImprovements, stepSize)
  referenceSet = []
  begin
    candidate = {}
    candidate[:vector] = random_solution(problemSize, searchSpace)
    candidate[:cost] = cost(candidate[:vector])
    candidate = local_search(candidate, searchSpace, maxNoImprovements, stepSize)
    referenceSet << candidate if !referenceSet.any? {|x| x[:vector]==candidate[:vector]}
  end until referenceSet.length == refSetSize
  return referenceSet
end

def distance(vector1, referenceSet)
  sum = 0
  referenceSet.each do |s|
    vector1.each_with_index {|v, i| sum += (v**2.0 - s[:vector][i]**2.0) }
  end
  return sum
end

def diversify(oldReferenceSet, numElite)
  oldReferenceSet.sort!{|x,y| x[:cost] <=> y[:cost]}
  referenceSet = Array.new(numElite){|i| oldReferenceSet[i]}
  remainder = oldReferenceSet - referenceSet
  remainder.sort!{|x,y| distance(y[:vector], referenceSet) <=> distance(x[:vector], referenceSet)}
  referenceSet = referenceSet + remainder[0..(oldReferenceSet.length-referenceSet.length)]
  return referenceSet, referenceSet[0]
end

def select_subsets(referenceSet, maxSubsets)
  additions = referenceSet.select{|c| c[:new]}
  remainder = referenceSet - additions
  subsets = []
  additions.each{|a| remainder.each{|r| subsets << [a,r]}}
  subsets.delete_at(rand(subsets.length)) until subsets.length == maxSubsets
  return subsets
end

def recombine(subset)
  # TODO
  
  candidate = {}
  candidate[:vector] = random_solution(problemSize, searchSpace)
  candidate[:cost] = cost(candidate[:vector])
  
  return [candidate]
end

def search(problemSize, searchSpace, numIterations, refSetSize, maxNoImprovements, stepSize, noElite, maxSubsets)
  referenceSet = construct_initial_reference_set(problemSize, searchSpace, refSetSize, maxNoImprovements, stepSize)
  referenceSet, best = diversify(referenceSet, noElite)
  numIterations.times do |iter|
    wasChange = false    
    referenceSet.each{|c| c[:new] = false}
    subsets = select_subsets(referenceSet, maxSubsets)
    subsets.each do |subset|
      candidates = recombine(subset)
      improved = Array.new(candidates.length) {|c| local_search(c, searchSpace, maxNoImprovements, stepSize)}
      improved.each do |c|
        if !referenceSet.any? {|x| x[:vector]==c[:vector]}
          c[:new] = true
          if referenceSet.sort!{|x,y| x[:cost] <=> y[:cost]} and c[:cost]<referenceSet.last[:cost]
            referenceSet.remove(referenceSet.last)
            referenceSet << c
            wasChange = true
          else
            referenceSet.sort!{|x,y| distance(y[:vector], referenceSet) <=> distance(x[:vector], referenceSet)}
            if distance(c[:vector], referenceSet) > distance(referenceSet.last[:vector], referenceSet)
              referenceSet.remove(referenceSet.last)
              referenceSet << c
              wasChange = true
            end
          end
        end
      end
    end
    puts " > iteration #{(iter+1)}, best: c=#{best[:cost]}"
  end
  return best
end

best = search(PROBLEM_SIZE, SEARCH_SPACE, NUM_ITERATIONS, REF_SET_SIZE, LS_MAX_NO_IMPROVEMENTS, STEP_SIZE, NO_ELITE, MAX_SUBSET)
puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"