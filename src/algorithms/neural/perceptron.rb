# Perceptron Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

# TODO

def search()
   
  max_gens.times do |gen|
     
    puts " > gen #{gen+1}, rmse=#{best[:error]}"
  end
  return best
end

if __FILE__ == $0
  

  best = search()
  puts "done! Solution: f=#{best[:error]}"
end