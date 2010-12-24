# Bacterial Foraging Optimization Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def objective_function(vector)
  return vector.inject(0.0) {|sum, x| sum +  (x ** 2.0)}
end

def random_vector(search_space)
  return Array.new(search_space.size) do |i|      
    search_space[i][0] + ((search_space[i][1] - search_space[i][0]) * rand())
  end
end

def generate_random_direction(problem_size)
  bounds = Array.new(problem_size){[-1.0,1.0]}
  return random_vector(bounds)
end

def compute_cell_interaction(cell, cells, d, w)
  sum = 0.0
  cells.each do |other|
    diff = 0.0
    other[:vector].each_with_index do |other_value,i|
      diff += (cell[:vector][i] - other_value)**2.0
    end
    sum += d * Math.exp(w * diff)
  end
  return sum
end

def compute_attract_repel(cell, cells, d_attr, w_attr, h_rep, w_rep)
  attract = compute_cell_interaction(cell, cells, -d_attr, -w_attr)
  repel = compute_cell_interaction(cell, cells, h_rep, -w_rep)
  return attract + repel
end

def evaluate(cell, cells, d_attr, w_attr, h_rep, w_rep)
  cell[:cost] = objective_function(cell[:vector])
  cell[:interaction] = compute_attract_repel(cell, cells, d_attr, w_attr, h_rep, w_rep)
  cell[:fitness] = cell[:cost] + cell[:interaction]
end

def tumble_cell(problem_size, cell, step_size)
  step = generate_random_direction(problem_size)  
  vector = Array.new(problem_size) do |i|
    cell[:vector][i] + step_size * step[i]
  end
  return {:vector=>vector}
end

def chemotaxis(cells, search_space, chem_steps, swim_length, step_size, d_attr, w_attr, h_rep, w_rep) 
  best = nil
  chem_steps.times do |j|
    moved_cells = []   
    cells.each_with_index do |cell, i|
      sum_nutrients = 0.0
      evaluate(cell, cells, d_attr, w_attr, h_rep, w_rep)          
      best = cell if best.nil? or cell[:cost] < best[:cost]
      sum_nutrients += cell[:fitness]
      swim_length.times do |m|
        new_cell = tumble_cell(search_space.size, cell, step_size)
        evaluate(new_cell, cells, d_attr, w_attr, h_rep, w_rep)          
        best = cell if cell[:cost] < best[:cost]
        break if new_cell[:fitness] > cell[:fitness]
        cell = new_cell
        sum_nutrients += cell[:fitness]
      end
      cell[:sum_nutrients] = sum_nutrients
      moved_cells << cell
    end        
    puts " >chemotaxis=#{j}, fitness=#{best[:fitness]}, cost=#{best[:cost]}"
    cells = moved_cells
  end
  return [best, cells]
end

def search(search_space, pop_size, elim_disp_steps, repro_steps, chem_steps, swim_length, step_size, d_attr, w_attr, h_rep, w_rep, p_eliminate)  
  cells = Array.new(pop_size) { {:vector=>random_vector(search_space)} }
  best = nil
  elim_disp_steps.times do |l|
    repro_steps.times do |k|      
      c_best, cells = chemotaxis(cells, search_space, chem_steps, swim_length, step_size, d_attr, w_attr, h_rep, w_rep) 
      best = c_best if best.nil? or c_best[:cost] < best[:cost]
      cells.sort{|x,y| x[:sum_nutrients]<=>y[:sum_nutrients]}
      cells = cells[0...(pop_size/2)] + cells[0...(pop_size/2)]
    end
    cells.each do |cell|
      if rand() <= p_eliminate
        cell[:vector] = random_vector(search_space) 
      end
    end    
  end
  return best
end

if __FILE__ == $0
  # problem configuration
  problem_size = 2
  search_space = Array.new(problem_size) {|i| [-5, 5]}
  # algorithm configuration
  pop_size = 50
  step_size = 0.1 # Ci
  elim_disp_steps = 1 # Ned
  repro_steps = 4 # Nre
  chem_steps = 70 # Nc
  swim_length = 4 # Ns
  p_eliminate = 0.25 # Ped
  d_attr = 0.1
  w_attr = 0.2 
  h_rep = d_attr
  w_rep = 10
  # execute the algorithm
  best = search(search_space, pop_size, elim_disp_steps, repro_steps, chem_steps, swim_length, step_size, d_attr, w_attr, h_rep, w_rep, p_eliminate)
  puts "done! Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"
end
