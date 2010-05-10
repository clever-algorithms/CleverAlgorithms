# Differential Evolution in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def objective_function(vector)
  return vector.inject(0.0) {|sum, x| sum +  (x ** 2.0)}
end

def random_vector(problem_size, search_space)
  return Array.new(problem_size) do |i|      
    search_space[i][0] + ((search_space[i][1] - search_space[i][0]) * rand())
  end
end

def new_sample(p0, p1, p2, p3, f, cr, search_space)
  length = p0[:vector].length
  sample = {}
  sample[:vector] = []
  cut = rand(length-1) + 1
  length.times do |i|
    if (i==cut or rand() < cr)
      v = p3[:vector][i] + f * (p1[:vector][i] - p2[:vector][i])
      v = search_space[i][0] if v < search_space[i][0]
      v = search_space[i][1] if v > search_space[i][1]
      sample[:vector] << v
    else
      sample[:vector] << p0[:vector][i]
    end
  end
  return sample
end

def search(max_generations, np, search_space, g, f, cr)
  pop = Array.new(g) {|i| {:vector=>random_vector(np, search_space)} }
  pop.each{|c| c[:cost] = objective_function(c[:vector])}
  gen, best = 0, pop.sort{|x,y| x[:cost] <=> y[:cost]}.first  
  max_generations.times do |gen|
    samples = []
    pop.each_with_index do |p0, i|
      p1 = p2 = p3 = -1
      p1 = rand(pop.length) until p1!=i
      p2 = rand(pop.length) until p2!=i and p2!=p1
      p3 = rand(pop.length) until p3!=i and p3!=p1 and p3!=p2
      samples << new_sample(p0, pop[p1], pop[p2], pop[p3], f, cr, search_space)
    end
    samples.each{|c| c[:cost] = objective_function(c[:vector])}
    nextgen = Array.new(g) do |i| 
      (samples[i][:cost]<=pop[i][:cost]) ? samples[i] : pop[i]
    end
    pop = nextgen    
    pop.sort!{|x,y| x[:cost] <=> y[:cost]}
    best = pop.first if pop.first[:cost] < best[:cost]
    puts " > gen #{gen+1}, fitness=#{best[:cost]}"
  end  
  return best
end


problem_size = 3
max_generations = 200
pop_size = 10*problem_size
weighting_factor = 0.8
crossover_factor = 0.9
search_space = Array.new(problem_size) {|i| [-5, +5]}

best = search(max_generations, problem_size, search_space, pop_size, weighting_factor, crossover_factor)
puts "done! Solution: f=#{best[:cost]}, s=#{best[:vector].inspect}"