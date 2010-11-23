# Self-Organizing Map Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def random_vector(minmax)
  return Array.new(minmax.length) do |i|      
    minmax[i][0] + ((minmax[i][1] - minmax[i][0]) * rand())
  end
end

def generate_random_pattern(domain)  
  classes = domain.keys
  selected_class = rand(classes.length)
  pattern = {}
  pattern[:class_number] = selected_class
  pattern[:class_label] = classes[selected_class]
  pattern[:vector] = random_vector(domain[classes[selected_class]])
  return pattern
end

def initialize_vectors(domain, num_vectors)
  classes = domain.keys
  codebook_vectors = []
  num_vectors.times do 
    selected_class = rand(classes.length)
    codebook = {}
    codebook[:class_label] = classes[selected_class]
    codebook[:vector] = random_vector([[0,1],[0,1]])
    codebook_vectors << codebook
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
    dist = euclidean_distance(codebook[:vector], pattern[:vector])
    best,b_dist = codebook,dist if b_dist.nil? or dist<b_dist
  end
  return best
end

def update_codebook_vector(bmu, pattern, lrate)
  bmu[:vector].each_with_index do |v,i|
    error = pattern[:vector][i]-bmu[:vector][i]
    if bmu[:class_label] == pattern[:class_label] 
      bmu[:vector][i] += lrate * error 
    else
      bmu[:vector][i] -= lrate * error
    end
  end
end

def train_network(codebook_vectors, domain, problem_size, iterations, learning_rate)
  iterations.times do |iter|
    pattern = generate_random_pattern(domain)
    bmu = get_best_matching_unit(codebook_vectors, pattern)
    lrate = learning_rate * (1.0-(iter.to_f/iterations.to_f))
    puts "> train lrate=#{lrate} got=#{bmu[:class_label]}, exp=#{pattern[:class_label]}"    
    update_codebook_vector(bmu, pattern, lrate)
  end
end

def test_network(codebook_vectors, domain)
  correct = 0
  100.times do 
    pattern = generate_random_pattern(domain)
    bmu = get_best_matching_unit(codebook_vectors, pattern)
    correct += 1 if bmu[:class_label] == pattern[:class_label]
  end
  puts "Finished test with a score of #{correct}/#{100} (#{(correct/100)*100}%)"
end

def run(domain, problem_size, iterations, num_vectors, learning_rate)  
  codebook_vectors = initialize_vectors(domain, num_vectors)
  train_network(codebook_vectors, domain, problem_size, iterations, learning_rate)
  test_network(codebook_vectors, domain)
end

if __FILE__ == $0
  problem_size = 2
  domain = {"A"=>[[0,0.4999999],[0,0.4999999]],"B"=>[[0.5,1],[0.5,1]]}
  learning_rate = 0.3
  iterations = 1000
  num_vectors = 20

  run(domain, problem_size, iterations, num_vectors, learning_rate)
end