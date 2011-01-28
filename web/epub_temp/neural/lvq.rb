# Learning Vector Quantization Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def random_vector(minmax)
  return Array.new(minmax.size) do |i|      
    minmax[i][0] + ((minmax[i][1] - minmax[i][0]) * rand())
  end
end

def generate_random_pattern(domain)  
  classes = domain.keys
  selected_class = rand(classes.size)
  pattern = {:label=>classes[selected_class]}
  pattern[:vector] = random_vector(domain[classes[selected_class]])
  return pattern
end

def initialize_vectors(domain, num_vectors)
  classes = domain.keys
  codebook_vectors = []
  num_vectors.times do 
    selected_class = rand(classes.size)
    codebook = {}
    codebook[:label] = classes[selected_class]
    codebook[:vector] = random_vector([[0,1],[0,1]])
    codebook_vectors << codebook
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
    dist = euclidean_distance(codebook[:vector], pattern[:vector])
    best,b_dist = codebook,dist if b_dist.nil? or dist<b_dist
  end
  return best
end

def update_codebook_vector(bmu, pattern, lrate)
  bmu[:vector].each_with_index do |v,i|
    error = pattern[:vector][i]-bmu[:vector][i]
    if bmu[:label] == pattern[:label] 
      bmu[:vector][i] += lrate * error 
    else
      bmu[:vector][i] -= lrate * error
    end
  end
end

def train_network(codebook_vectors, domain, iterations, learning_rate)
  iterations.times do |iter|
    pat = generate_random_pattern(domain)
    bmu = get_best_matching_unit(codebook_vectors, pat)
    lrate = learning_rate * (1.0-(iter.to_f/iterations.to_f))
    if iter.modulo(10)==0
      puts "> iter=#{iter}, got=#{bmu[:label]}, exp=#{pat[:label]}"
    end
    update_codebook_vector(bmu, pat, lrate)
  end
end

def test_network(codebook_vectors, domain, num_trials=100)
  correct = 0
  num_trials.times do 
    pattern = generate_random_pattern(domain)
    bmu = get_best_matching_unit(codebook_vectors, pattern)
    correct += 1 if bmu[:label] == pattern[:label]
  end
  puts "Done. Score: #{correct}/#{num_trials}"
  return correct
end

def execute(domain, iterations, num_vectors, learning_rate)  
  codebook_vectors = initialize_vectors(domain, num_vectors)
  train_network(codebook_vectors, domain, iterations, learning_rate)
  test_network(codebook_vectors, domain)
  return codebook_vectors
end

if __FILE__ == $0
  # problem configuration
  domain = {"A"=>[[0,0.4999999],[0,0.4999999]],"B"=>[[0.5,1],[0.5,1]]}
  # algorithm configuration
  learning_rate = 0.3
  iterations = 1000
  num_vectors = 20
  # execute the algorithm
  execute(domain, iterations, num_vectors, learning_rate)
end