# Variable Neighborhood Search in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def euc_2d(c1, c2)
  Math.sqrt((c1[0] - c2[0])**2.0 + (c1[1] - c2[1])**2.0).round
end

def random_permutation(cities)
  perm = Array.new(cities.size){|i|i}
  for i in 0...perm.size
    r = rand(perm.size-i) + i
    perm[r], perm[i] = perm[i], perm[r]
  end
  return perm
end

def stochastic_two_opt!(perm)
  c1, c2 = rand(perm.size), rand(perm.size)
  c2 = rand(perm.size) while c1 == c2
  c1, c2 = c2, c1 if c2 < c1
  perm[c1...c2] = perm[c1...c2].reverse
  return perm
end

def cost(permutation, cities)
  distance =0
  permutation.each_with_index do |c1, i|
    c2 = (i==permutation.size-1) ? permutation[0] : permutation[i+1]
    distance += euc_2d(cities[c1], cities[c2])
  end
  return distance
end

def local_search(best, cities, max_no_improvements, neighborhood)
  count = 0
  begin
    candidate = {}
    candidate[:vector] = Array.new(best[:vector])
    neighborhood.times{stochastic_two_opt!(candidate[:vector])}
    candidate[:cost] = cost(candidate[:vector], cities)
    if candidate[:cost] < best[:cost]
      count, best = 0, candidate
    else
      count += 1      
    end
  end until count >= max_no_improvements
  return best
end

def search(cities, neighborhoods, max_no_improvements, max_no_improvements_ls)
  best = {}
  best[:vector] = random_permutation(cities)
  best[:cost] = cost(best[:vector], cities)
  iter, count = 0, 0
  begin
    neighborhoods.each do |neighborhood|
      candidate = {}
      candidate[:vector] = Array.new(best[:vector])      
      neighborhood.times{stochastic_two_opt!(candidate[:vector])}
      candidate[:cost] = cost(candidate[:vector], cities)
      candidate = local_search(candidate, cities, max_no_improvements_ls, neighborhood)      
      puts " > iteration #{(iter+1)}, neighborhood=#{neighborhood}, best=#{best[:cost]}"
      iter += 1
      if(candidate[:cost] < best[:cost])
        best = candidate
        count = 0
        puts "New best, restarting neighborhood search."
        break
      else
        count += 1
      end
    end  
  end until count >= max_no_improvements
  return best
end

if __FILE__ == $0
  # problem configuration
  berlin52 = [[565,575],[25,185],[345,750],[945,685],[845,655],
   [880,660],[25,230],[525,1000],[580,1175],[650,1130],[1605,620],
   [1220,580],[1465,200],[1530,5],[845,680],[725,370],[145,665],
   [415,635],[510,875],[560,365],[300,465],[520,585],[480,415],
   [835,625],[975,580],[1215,245],[1320,315],[1250,400],[660,180],
   [410,250],[420,555],[575,665],[1150,1160],[700,580],[685,595],
   [685,610],[770,610],[795,645],[720,635],[760,650],[475,960],
   [95,260],[875,920],[700,500],[555,815],[830,485],[1170,65],
   [830,610],[605,625],[595,360],[1340,725],[1740,245]]
  # algorithm configuration
  max_no_mprovements = 50
  local_search_no_improvements = 70
  neighborhoods = 1...20
  # execute the algorithm
  best = search(berlin52, neighborhoods, max_no_mprovements, local_search_no_improvements)
  puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"
end
