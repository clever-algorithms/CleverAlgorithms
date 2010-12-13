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

def euclidean_distance(v1, v2)
  sum = 0.0
  v1.each_with_index do |v, i|
    sum += (v1[i]-v2[i])**2.0
  end
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

def train_network(codebook_vectors, shape, iterations, learning_rate, neighborhood_size)
  iterations.times do |iter|
    pattern = random_vector(shape)
    lrate = learning_rate * (1.0-(iter.to_f/iterations.to_f))
    neigh_size = neighborhood_size * (1.0-(iter.to_f/iterations.to_f))
    bmu,dist = get_best_matching_unit(codebook_vectors, pattern)
    neighbors = get_vectors_in_neighborhood(bmu, codebook_vectors, neigh_size)
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
end

def test_network(codebook_vectors, shape)
  error = 0.0
  100.times do 
    pattern = random_vector(shape)
    bmu,dist = get_best_matching_unit(codebook_vectors, pattern)
    error += dist
  end
  error /= 100.0
  puts "Finished, average error=#{error}"  
end

def run(domain, shape, iterations, learning_rate, neighborhood_size, width, height)  
  codebook_vectors = initialize_vectors(domain, width, height)
  summarize_vectors(codebook_vectors)
  train_network(codebook_vectors, shape, iterations, learning_rate, neighborhood_size)
  test_network(codebook_vectors, shape)
  summarize_vectors(codebook_vectors)
end

if __FILE__ == $0
  # problem configuration
  domain = [[0.0,1.0],[0.0,1.0]]
  shape = [[0.3,0.6],[0.3,0.6]]
  # algorithm configuration
  iterations = 100
  learning_rate = 0.3
  neighborhood_size = 5
  width, height = 4, 5
  # execute the algorithm
  run(domain, shape, iterations, learning_rate, neighborhood_size, width, height)
end