# Cross-Entropy Method algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def objective_function(vector)
  return vector.inject(0.0) {|sum, x| sum +  (x ** 2.0)}
end

def random_variable(minmax)
  min, max = minmax
  return min + ((max - min) * rand())
end

def random_gaussian(mean=0.0, stdev=1.0)
  u1 = u2 = w = 0
  begin
    u1 = 2 * rand() - 1
    u2 = 2 * rand() - 1
    w = u1 * u1 + u2 * u2
  end while w >= 1
  w = Math.sqrt((-2.0 * Math.log(w)) / w)
  return mean + (u2 * w) * stdev
end

def generate_sample(search_space, means, stdevs)
  vector = Array.new(search_space.size)
  search_space.size.times do |i|
    vector[i] = random_gaussian(means[i], stdevs[i])
    vector[i] = search_space[i][0] if vector[i] < search_space[i][0]
    vector[i] = search_space[i][1] if vector[i] > search_space[i][1]
  end
  return {:vector=>vector}
end

def mean_attr(samples, i)
  sum = samples.inject(0.0) do |s,sample| 
    s + sample[:vector][i]
  end 
  return (sum / samples.size.to_f)
end

def stdev_attr(samples, mean, i)
  sum = samples.inject(0.0) do |s,sample| 
    s + (sample[:vector][i] - mean)**2.0
  end 
  return Math.sqrt(sum / samples.size.to_f)
end

def update_distribution!(samples, alpha, means, stdevs)
  means.size.times do |i|
    means[i] = alpha*means[i] + ((1.0-alpha)*mean_attr(samples, i))
    stdevs[i] = alpha*stdevs[i]+((1.0-alpha)*stdev_attr(samples,means[i],i))
  end
end

def search(bounds, max_iter, num_samples, num_update, learning_rate)
  means = Array.new(bounds.size){|i| random_variable(bounds[i])}
  stdevs = Array.new(bounds.size){|i| bounds[i][1]-bounds[i][0]}
  best = nil
  max_iter.times do |iter|
    samples = Array.new(num_samples){generate_sample(bounds, means, stdevs)}
    samples.each {|samp| samp[:cost] = objective_function(samp[:vector])}
    samples.sort!{|x,y| x[:cost]<=>y[:cost]}
    best = samples.first if best.nil? or samples.first[:cost] < best[:cost]
    selected = samples.first(num_update)
    update_distribution!(selected, learning_rate, means, stdevs)
    puts " > iteration=#{iter}, fitness=#{best[:cost]}"
  end
  return best
end

if __FILE__ == $0
  # problem configuration
  problem_size = 3
  search_space = Array.new(problem_size) {|i| [-5, 5]}
  # algorithm configuration
  max_iter = 100
  num_samples = 50
  num_update = 5
  l_rate = 0.7
  # execute the algorithm
  best = search(search_space, max_iter, num_samples, num_update, l_rate)
  puts "done! Solution: f=#{best[:cost]}, s=#{best[:vector].inspect}"
end