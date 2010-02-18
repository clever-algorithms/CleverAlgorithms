# Scatter Search algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

NUM_ITERATIONS = 100
PROBLEM_SIZE = 3
SEARCH_SPACE = Array.new(PROBLEM_SIZE) {|i| [-5, +5]}
STEP_SIZE = (SEARCH_SPACE[0][1]-SEARCH_SPACE[0][0])*0.005
LS_MAX_NO_IMPROVEMENTS = 30
REF_SET_SIZE = 10
DIVERSE_SET_SIZE = 20
NO_ELITE = 5

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

def construct_initial_set(problemSize, searchSpace, divSetSize, maxNoImprovements, stepSize)
  diverseSet = []
  begin
    candidate = {}
    candidate[:vector] = random_solution(problemSize, searchSpace)
    candidate[:cost] = cost(candidate[:vector])
    candidate = local_search(candidate, searchSpace, maxNoImprovements, stepSize)
    diverseSet << candidate if !diverseSet.any? {|x| x[:vector]==candidate[:vector]}
  end until diverseSet.length == divSetSize
  return diverseSet
end

def euclidean(v1, v2)
  sum = 0.0
  v1.each_with_index {|v, i| sum += (v**2.0 - v2[i]**2.0) }
  sum = sum + (0.0-sum) if sum < 0.0
  return Math.sqrt(sum)
end

def distance(vector1, referenceSet)
  sum = 0.0
  referenceSet.each do |s|
    sum += euclidean(vector1, s[:vector])
  end
  return sum
end

def diversify(diverseSet, numElite, refSetSize)
  diverseSet.sort!{|x,y| x[:cost] <=> y[:cost]}
  referenceSet = Array.new(numElite){|i| diverseSet[i]}
  remainder = diverseSet - referenceSet
  remainder.sort!{|x,y| distance(y[:vector], referenceSet) <=> distance(x[:vector], referenceSet)}
  referenceSet = referenceSet + remainder[0..(refSetSize-referenceSet.length)]
  return referenceSet, referenceSet[0]
end

def select_subsets(referenceSet)
  additions = referenceSet.select{|c| c[:new]}
  remainder = referenceSet - additions
  remainder = additions if remainder.empty?
  subsets = []
  additions.each{|a| remainder.each{|r| subsets << [a,r] if a!=r}}
  return subsets
end

def recombine(subset, problemSize, searchSpace)
  a, b = subset
  d = rand(euclidean(a[:vector], b[:vector]))/2.0
  children = []
  subset.each do |p|
    step = (rand<0.5) ? +d : -d
    child = {}
    child[:vector] = Array.new(problemSize){|i| p[:vector][i]+step}
    child[:vector].each_with_index {|m,i| child[:vector][i]=searchSpace[i][0] if m<searchSpace[i][0]}
    child[:vector].each_with_index {|m,i| child[:vector][i]=searchSpace[i][1] if m>searchSpace[i][1]}
    child[:cost] = cost(child[:vector])
    children << child
  end
  return children
end

def search(problemSize, searchSpace, numIterations, refSetSize, divSetSize, maxNoImprovements, stepSize, noElite)
  diverseSet = construct_initial_set(problemSize, searchSpace, divSetSize, maxNoImprovements, stepSize)
  referenceSet, best = diversify(diverseSet, noElite, refSetSize)
  referenceSet.each{|c| c[:new] = true}
  numIterations.times do |iter|
    wasChange = false
    subsets = select_subsets(referenceSet)
    referenceSet.each{|c| c[:new] = false}
    subsets.each do |subset|
      candidates = recombine(subset, problemSize, searchSpace)
      improved = Array.new(candidates.length) {|i| local_search(candidates[i], searchSpace, maxNoImprovements, stepSize)}
      improved.each do |c|
        if !referenceSet.any? {|x| x[:vector]==c[:vector]}
          c[:new] = true
          referenceSet.sort!{|x,y| x[:cost] <=> y[:cost]}
          if c[:cost]<referenceSet.last[:cost]
            referenceSet.delete(referenceSet.last)
            referenceSet << c
            wasChange = true
          end
        end
      end
    end
    referenceSet.sort!{|x,y| x[:cost] <=> y[:cost]}
    best = referenceSet[0] if referenceSet[0][:cost] < best[:cost]
    puts " > iteration #{(iter+1)}, best: c=#{best[:cost]}"
    break if !wasChange
  end
  return best
end

best = search(PROBLEM_SIZE, SEARCH_SPACE, NUM_ITERATIONS, REF_SET_SIZE, DIVERSE_SET_SIZE, LS_MAX_NO_IMPROVEMENTS, STEP_SIZE, NO_ELITE)
puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"