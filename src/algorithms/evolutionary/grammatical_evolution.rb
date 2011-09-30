# Grammatical Evolution in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def binary_tournament(pop)
  i, j = rand(pop.size), rand(pop.size)
  j = rand(pop.size) while j==i
  return (pop[i][:fitness] < pop[j][:fitness]) ? pop[i] : pop[j]
end

def point_mutation(bitstring, rate=1.0/bitstring.size.to_f)
  child = ""
  bitstring.size.times do |i|
    bit = bitstring[i].chr
    child << ((rand()<rate) ? ((bit=='1') ? "0" : "1") : bit)
  end
  return child
end

def one_point_crossover(parent1, parent2, codon_bits, p_cross=0.30)
  return ""+parent1[:bitstring] if rand()>=p_cross
  cut = rand([parent1[:bitstring].size, parent2[:bitstring].size].min/codon_bits)
  cut *= codon_bits
  p2size = parent2[:bitstring].size
  return parent1[:bitstring][0...cut]+parent2[:bitstring][cut...p2size]
end

def codon_duplication(bitstring, codon_bits, rate=1.0/codon_bits.to_f)
  return bitstring if rand() >= rate
  codons = bitstring.size/codon_bits  
  return bitstring + bitstring[rand(codons)*codon_bits, codon_bits]
end

def codon_deletion(bitstring, codon_bits, rate=0.5/codon_bits.to_f)
  return bitstring if rand() >= rate
  codons = bitstring.size/codon_bits  
  off = rand(codons)*codon_bits
  return bitstring[0...off] + bitstring[off+codon_bits...bitstring.size]
end

def reproduce(selected, pop_size, p_cross, codon_bits)
  children = []
  selected.each_with_index do |p1, i|    
    p2 = (i.modulo(2)==0) ? selected[i+1] : selected[i-1]
    p2 = selected[0] if i == selected.size-1
    child = {}
    child[:bitstring] = one_point_crossover(p1, p2, codon_bits, p_cross)
    child[:bitstring] = codon_deletion(child[:bitstring], codon_bits)
    child[:bitstring] = codon_duplication(child[:bitstring], codon_bits)
    child[:bitstring] = point_mutation(child[:bitstring])
    children << child
    break if children.size == pop_size
  end
  return children
end

def random_bitstring(num_bits)
  return (0...num_bits).inject(""){|s,i| s<<((rand<0.5) ? "1" : "0")}
end

def decode_integers(bitstring, codon_bits)
  ints = []
  (bitstring.size/codon_bits).times do |off|
    codon = bitstring[off*codon_bits, codon_bits]
    sum = 0
    codon.size.times do |i| 
      sum += ((codon[i].chr=='1') ? 1 : 0) * (2 ** i);
    end
    ints << sum
  end
  return ints
end

def map(grammar, integers, max_depth)
  done, offset, depth = false, 0, 0
  symbolic_string = grammar["S"]
  begin
    done = true
    grammar.keys.each do |key|
      symbolic_string = symbolic_string.gsub(key) do |k|
        done = false
        set = (k=="EXP" && depth>=max_depth-1) ? grammar["VAR"] : grammar[k]
        integer = integers[offset].modulo(set.size)
        offset = (offset==integers.size-1) ? 0 : offset+1
        set[integer]
      end
    end
    depth += 1
  end until done
  return symbolic_string
end

def target_function(x)
  return x**4.0 + x**3.0 + x**2.0 + x
end

def sample_from_bounds(bounds)
  return bounds[0] + ((bounds[1] - bounds[0]) * rand())
end

def cost(program, bounds, num_trials=30)
  return 9999999 if program.strip == "INPUT"
  sum_error = 0.0    
  num_trials.times do
    x = sample_from_bounds(bounds)
    expression = program.gsub("INPUT", x.to_s)
    begin score = eval(expression) rescue score = 0.0/0.0 end
    return 9999999 if score.nan? or score.infinite?
    sum_error += (score - target_function(x)).abs
  end
  return sum_error / num_trials.to_f
end

def evaluate(candidate, codon_bits, grammar, max_depth, bounds)
  candidate[:integers] = decode_integers(candidate[:bitstring], codon_bits)
  candidate[:program] = map(grammar, candidate[:integers], max_depth)
  candidate[:fitness] = cost(candidate[:program], bounds)
end

def search(max_gens, pop_size, codon_bits, num_bits, p_cross, grammar, max_depth, bounds)
  pop = Array.new(pop_size) {|i| {:bitstring=>random_bitstring(num_bits)}}
  pop.each{|c| evaluate(c,codon_bits, grammar, max_depth, bounds)}
  best = pop.sort{|x,y| x[:fitness] <=> y[:fitness]}.first
  max_gens.times do |gen|
    selected = Array.new(pop_size){|i| binary_tournament(pop)}
    children = reproduce(selected, pop_size, p_cross,codon_bits)    
    children.each{|c| evaluate(c, codon_bits, grammar, max_depth, bounds)}
    children.sort!{|x,y| x[:fitness] <=> y[:fitness]}
    best = children.first if children.first[:fitness] <= best[:fitness]
    pop=(children+pop).sort{|x,y| x[:fitness]<=>y[:fitness]}.first(pop_size)
    puts " > gen=#{gen}, f=#{best[:fitness]}, s=#{best[:bitstring]}"
    break if best[:fitness] == 0.0
  end  
  return best
end

if __FILE__ == $0
  # problem configuration
  grammar = {"S"=>"EXP",
    "EXP"=>[" EXP BINARY EXP ", " (EXP BINARY EXP) ", " VAR "],
    "BINARY"=>["+", "-", "/", "*" ],
    "VAR"=>["INPUT", "1.0"]}
  bounds = [1, 10]
  # algorithm configuration
  max_depth = 7
  max_gens = 50
  pop_size = 100
  codon_bits = 4
  num_bits = 10*codon_bits
  p_cross = 0.30
  # execute the algorithm
  best = search(max_gens, pop_size, codon_bits, num_bits, p_cross, grammar, max_depth, bounds)
  puts "done! Solution: f=#{best[:fitness]}, s=#{best[:program]}"
end
