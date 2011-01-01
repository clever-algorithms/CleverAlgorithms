# Scatter Search algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def objective_function(vector)
  return vector.inject(0) {|sum, x| sum +  (x ** 2.0)}
end

def rand_in_bounds(min, max)
  return min + ((max-min) * rand()) 
end

def random_vector(minmax)
  return Array.new(minmax.size) do |i|      
    rand_in_bounds(minmax[i][0], minmax[i][1])
  end
end

def take_step(minmax, current, step_size)
  position = Array.new(current.size)
  position.size.times do |i|
    min = [minmax[i][0], current[i]-step_size].max
    max = [minmax[i][1], current[i]+step_size].min
    position[i] = rand_in_bounds(min, max)
  end
  return position
end

def local_search(best, search_space, max_no_improv, step_size)
  count = 0
  begin
    candidate = {:vector=>take_step(search_space, best[:vector], step_size)}
    candidate[:cost] = objective_function(candidate[:vector])
    count = (candidate[:cost] < best[:cost]) ? 0 : count+1
    best = candidate if candidate[:cost] < best[:cost]    
  end until count >= max_no_improv
  return best
end

def construct_initial_set(search_space, set_size, max_no_improv, step_size)
  diverse_set = []
  begin
    candidate = {:vector=>random_vector(search_space)}
    candidate[:cost] = objective_function(candidate[:vector])
    candidate = local_search(candidate, search_space, max_no_improv, step_size)
    diverse_set << candidate if !diverse_set.any? {|x| x[:vector]==candidate[:vector]}
  end until diverse_set.size == set_size
  return diverse_set
end

def euclidean_distance(c1, c2)
  sum = 0.0
  c1.each_index {|i| sum += (c1[i]-c2[i])**2.0}  
  return Math.sqrt(sum)
end

def distance(v, set)
  return set.inject(0){|s,x| s + euclidean_distance(v, x[:vector])}
end

def diversify(diverse_set, num_elite, ref_set_size)
  diverse_set.sort!{|x,y| x[:cost] <=> y[:cost]}
  reference_set = Array.new(num_elite){|i| diverse_set[i]}
  remainder = diverse_set - reference_set
  remainder.each{|c| c[:dist] = distance(c[:vector], reference_set)}
  remainder.sort!{|x,y| y[:dist]<=>x[:dist]}
  reference_set = reference_set + remainder.first(ref_set_size-reference_set.size)
  return [reference_set, reference_set[0]]
end

def select_subsets(reference_set)
  additions = reference_set.select{|c| c[:new]}
  remainder = reference_set - additions
  remainder = additions if remainder.nil? or remainder.empty?
  subsets = []
  additions.each do |a| 
    remainder.each{|r| subsets << [a,r] if a!=r and !subsets.include?([r,a])}
  end
  return subsets
end

def recombine(subset, minmax)
  a, b = subset
  d = rand(euclidean_distance(a[:vector], b[:vector]))/2.0
  children = []
  subset.each do |p|
    step = (rand<0.5) ? +d : -d
    child = {:vector=>Array.new(minmax.size)}
    child[:vector].each_index do |i|
      child[:vector][i] = p[:vector][i] + step
      child[:vector][i]=minmax[i][0] if child[:vector][i]<minmax[i][0]
      child[:vector][i]=minmax[i][1] if child[:vector][i]>minmax[i][1]
    end
    child[:cost] = objective_function(child[:vector])
    children << child
  end
  return children
end

def explore_subsets(search_space, reference_set, max_no_improv, step_size)
  was_change = false
  subsets = select_subsets(reference_set)
  reference_set.each{|c| c[:new] = false}
  subsets.each do |subset|
    candidates = recombine(subset, search_space)
    improved = Array.new(candidates.size) {|i| local_search(candidates[i], search_space, max_no_improv, step_size)}
    improved.each do |c|
      if !reference_set.any? {|x| x[:vector]==c[:vector]}
        c[:new] = true
        reference_set.sort!{|x,y| x[:cost] <=> y[:cost]}
        if c[:cost] < reference_set.last[:cost]
          reference_set.delete(reference_set.last)
          reference_set << c
          puts "  >> added, cost=#{c[:cost]}"
          was_change = true
        end
      end
    end
  end
  return was_change
end

def search(search_space, max_iter, ref_set_size, div_set_size, max_no_improv, step_size, max_elite)
  diverse_set = construct_initial_set(search_space, div_set_size, max_no_improv, step_size)
  reference_set, best = diversify(diverse_set, max_elite, ref_set_size)
  reference_set.each{|c| c[:new] = true}
  max_iter.times do |iter|    
    was_change = explore_subsets(search_space, reference_set, max_no_improv, step_size)
    reference_set.sort!{|x,y| x[:cost] <=> y[:cost]}
    best = reference_set.first if reference_set.first[:cost] < best[:cost]
    puts " > iter=#{(iter+1)}, best=#{best[:cost]}"
    break if !was_change
  end
  return best
end

if __FILE__ == $0
  # problem configuration
  problem_size = 3
  search_space = Array.new(problem_size) {|i| [-5, +5]}
  # algorithm configuration
  max_iter = 100
  step_size = (search_space[0][1]-search_space[0][0])*0.005
  max_no_improv = 30
  ref_set_size = 10
  diverse_set_size = 20
  no_elite = 5
  # execute the algorithm
  best = search(search_space, max_iter, ref_set_size, diverse_set_size, max_no_improv, step_size, no_elite)
  puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"
end