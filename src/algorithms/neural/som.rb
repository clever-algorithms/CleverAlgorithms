# Self-Organizing Map Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def random_vector(minmax)
  return Array.new(minmax.size) do |i|      
    minmax[i][0] + ((minmax[i][1] - minmax[i][0]) * rand())
  end
end

def initialize_vectors(domain, width, height)
  codebook_vectors = []
  width.times do |x|
    height.times do |y|
      codebook = {}
      codebook[:vector] = random_vector(domain)
      codebook[:coord] = [x,y] 
      codebook_vectors << codebook
    end
  end
  return codebook_vectors
end

def euclidean_distance(c1, c2)
  sum = 0.0
  c1.each_index {|i| sum += (c1[i]-c2[i])**2.0}  
  return Math.sqrt(sum)
end

def get_best_matching_unit(codebook_vectors, pattern)
  best, b_dist = nil, nil
  codebook_vectors.each do |codebook|
    dist = euclidean_distance(codebook[:vector], pattern)
    best,b_dist = codebook,dist if b_dist.nil? or dist<b_dist
  end
  return [best, b_dist]
end

def get_vectors_in_neighborhood(bmu, codebook_vectors, neigh_size)
  neighborhood = []
  codebook_vectors.each do |other|
    if euclidean_distance(bmu[:coord], other[:coord]) <= neigh_size
      neighborhood << other 
    end
  end
  return neighborhood
end

def update_codebook_vector(codebook, pattern, lrate)
  codebook[:vector].each_with_index do |v,i|
    error = pattern[i]-codebook[:vector][i]
    codebook[:vector][i] += lrate * error 
  end
end

def train_network(vectors, shape, iterations, l_rate, neighborhood_size)
  iterations.times do |iter|
    pattern = random_vector(shape)
    lrate = l_rate * (1.0-(iter.to_f/iterations.to_f))
    neigh_size = neighborhood_size * (1.0-(iter.to_f/iterations.to_f))
    bmu,dist = get_best_matching_unit(vectors, pattern)
    neighbors = get_vectors_in_neighborhood(bmu, vectors, neigh_size)
    neighbors.each do |node|
      update_codebook_vector(node, pattern, lrate)
    end
    puts ">training: neighbors=#{neighbors.size}, bmu_dist=#{dist}"        
  end
end

def summarize_vectors(vectors)
  minmax = Array.new(vectors.first[:vector].size){[1,0]}
  vectors.each do |c|
    c[:vector].each_with_index do |v,i|
      minmax[i][0] = v if v<minmax[i][0]
      minmax[i][1] = v if v>minmax[i][1]
    end
  end
  s = ""
  minmax.each_with_index {|bounds,i| s << "#{i}=#{bounds.inspect} "}
  puts "Vector details: #{s}"
  return minmax
end

def test_network(codebook_vectors, shape, num_trials=100)
  error = 0.0
  num_trials.times do 
    pattern = random_vector(shape)
    bmu,dist = get_best_matching_unit(codebook_vectors, pattern)
    error += dist
  end
  error /= num_trials.to_f
  puts "Finished, average error=#{error}"  
  return error
end

def execute(domain, shape, iterations, l_rate, neigh_size, width, height)  
  vectors = initialize_vectors(domain, width, height)
  summarize_vectors(vectors)
  train_network(vectors, shape, iterations, l_rate, neigh_size)
  test_network(vectors, shape)
  summarize_vectors(vectors)
  return vectors
end

if __FILE__ == $0
  # problem configuration
  domain = [[0.0,1.0],[0.0,1.0]]
  shape = [[0.3,0.6],[0.3,0.6]]
  # algorithm configuration
  iterations = 100
  l_rate = 0.3
  neigh_size = 5
  width, height = 4, 5
  # execute the algorithm
  execute(domain, shape, iterations, l_rate, neigh_size, width, height)
end