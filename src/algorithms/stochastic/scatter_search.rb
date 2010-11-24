# Scatter Search algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def cost(candidate_vector)
  return candidate_vector.inject(0) {|sum, x| sum +  (x ** 2.0)}
end

def random_solution(problem_size, search_space)
  return Array.new(problem_size) do |i|      
    search_space[i][0] + ((search_space[i][1] - search_space[i][0]) * rand())
  end
end

def take_step(current, search_space, step_size)
  step = []
  current.length.times do |i|
    max, min = current[i]+step_size, current[i]-step_size
    max = search_space[i][1] if max > search_space[i][1]
    min = search_space[i][0] if min < search_space[i][0]
    step << min + ((max - min) * rand)
  end
  return step
end

def local_search(best, search_space, max_no_improvements, step_size)
  count = 0
  begin
    candidate = {}
    candidate[:vector] = take_step(best[:vector], search_space, step_size)    
    candidate[:cost] = cost(candidate[:vector])
    if candidate[:cost] < best[:cost]
      count, best = 0, candidate
    else
      count += 1
    end
  end until count >= max_no_improvements
  return best
end

def construct_initial_set(problem_size, search_space, div_set_size, max_no_improvements, step_size)
  diverse_set = []
  begin
    candidate = {}
    candidate[:vector] = random_solution(problem_size, search_space)
    candidate[:cost] = cost(candidate[:vector])
    candidate = local_search(candidate, search_space, max_no_improvements, step_size)
    diverse_set << candidate if !diverse_set.any? {|x| x[:vector]==candidate[:vector]}
  end until diverse_set.length == div_set_size
  return diverse_set
end

def euclidean(v1, v2)
  sum = 0.0
  v1.each_with_index {|v, i| sum += (v**2.0 - v2[i]**2.0) }
  sum = sum + (0.0-sum) if sum < 0.0
  return Math.sqrt(sum)
end

def distance(vector1, reference_set)
  sum = 0.0
  reference_set.each do |s|
    sum += euclidean(vector1, s[:vector])
  end
  return sum
end

def diversify(diverse_set, numElite, ref_set_size)
  diverse_set.sort!{|x,y| x[:cost] <=> y[:cost]}
  reference_set = Array.new(numElite){|i| diverse_set[i]}
  remainder = diverse_set - reference_set
  remainder.sort!{|x,y| distance(y[:vector], reference_set) <=> distance(x[:vector], reference_set)}
  reference_set = reference_set + remainder[0..(ref_set_size-reference_set.length)]
  return reference_set, reference_set[0]
end

def select_subsets(reference_set)
  additions = reference_set.select{|c| c[:new]}
  remainder = reference_set - additions
  remainder = additions if remainder.empty?
  subsets = []
  additions.each{|a| remainder.each{|r| subsets << [a,r] if a!=r}}
  return subsets
end

def recombine(subset, problem_size, search_space)
  a, b = subset
  d = rand(euclidean(a[:vector], b[:vector]))/2.0
  children = []
  subset.each do |p|
    step = (rand<0.5) ? +d : -d
    child = {}
    child[:vector] = Array.new(problem_size){|i| p[:vector][i]+step}
    child[:vector].each_with_index {|m,i| child[:vector][i]=search_space[i][0] if m<search_space[i][0]}
    child[:vector].each_with_index {|m,i| child[:vector][i]=search_space[i][1] if m>search_space[i][1]}
    child[:cost] = cost(child[:vector])
    children << child
  end
  return children
end

def search(problem_size, search_space, max_iterations, ref_set_size, div_set_size, max_no_improvements, step_size, max_elite)
  diverse_set = construct_initial_set(problem_size, search_space, div_set_size, max_no_improvements, step_size)
  reference_set, best = diversify(diverse_set, max_elite, ref_set_size)
  reference_set.each{|c| c[:new] = true}
  max_iterations.times do |iter|
    wasChange = false
    subsets = select_subsets(reference_set)
    reference_set.each{|c| c[:new] = false}
    subsets.each do |subset|
      candidates = recombine(subset, problem_size, search_space)
      improved = Array.new(candidates.length) {|i| local_search(candidates[i], search_space, max_no_improvements, step_size)}
      improved.each do |c|
        if !reference_set.any? {|x| x[:vector]==c[:vector]}
          c[:new] = true
          reference_set.sort!{|x,y| x[:cost] <=> y[:cost]}
          if c[:cost]<reference_set.last[:cost]
            reference_set.delete(reference_set.last)
            reference_set << c
            wasChange = true
          end
        end
      end
    end
    reference_set.sort!{|x,y| x[:cost] <=> y[:cost]}
    best = reference_set[0] if reference_set[0][:cost] < best[:cost]
    puts " > iteration #{(iter+1)}, best=#{best[:cost]}"
    break if !wasChange
  end
  return best
end

if __FILE__ == $0
  # problem configuration
  problem_size = 3
  search_space = Array.new(problem_size) {|i| [-5, +5]}
  # algorithm configuration
  num_iterations = 100
  step_size = (search_space[0][1]-search_space[0][0])*0.005
  max_no_improvements = 30
  ref_set_size = 10
  diverse_set_size = 20
  no_elite = 5
  # execute the algorithm
  best = search(problem_size, search_space, num_iterations, ref_set_size, diverse_set_size, max_no_improvements, step_size, no_elite)
  puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"
end