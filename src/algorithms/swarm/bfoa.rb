# Bacterial Foraging Optimization Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.



def search(max_gens)
 best = nil
  max_gens.times do |iter|

    puts " > iteration=#{iter}, f=#{best[:fitness]}, v=#{best[:vector]}"
  end  
  return best
end

if __FILE__ == $0
  max_generations = 100

  best = search(max_generations)
  puts "done! Solution: f=#{best[:fitness]}, s=#{best[:vector]}"
end