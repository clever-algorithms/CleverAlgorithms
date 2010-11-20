# Bacterial Foraging Optimization Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def objective_function(vector)
  return vector.inject(0.0) {|sum, x| sum +  (x ** 2.0)}
end

def random_vector(problem_size, search_space)
  return Array.new(problem_size) do |i|      
    search_space[i][0] + ((search_space[i][1] - search_space[i][0]) * rand())
  end
end

def generate_random_direction(problem_size)
  bounds = Array.new(problem_size){[-1.0,1.0]}
  return random_vector(problem_size, bounds)
end

def compute_cell_interaction(cell, cells, d, w)
  sum = 0.0
  cells.each do |c|
    diff = 0.0
    c[:vector].each_with_index do |v,i|
      diff += (cell[:vector][i] - v)**2.0
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

def swim_cell(cell, cells, step_size)
  
end



def search(problem_size, search_space, pop_size, elim_disp_steps, repro_steps, chem_steps, swim_length, step_size, d_attr, w_attr, h_rep, w_rep)  
  cells = Array.new(pop_size) { {:vector=>random_vector(problem_size, search_space)} }
  best = nil
  elim_disp_steps.times do |l|
    repro_steps.times do |k|
      chem_steps.times do |j|
        moved_cells = []   
        cells.each_with_index do |cell, i|
          evaluate(cell, cells, d_attr, w_attr, h_rep, w_rep)          
          best = cell if best.nil? or cell[:cost] < best[:cost]
          swim_length.times do |m|
            new_cell = tumble_cell(problem_size, cell, step_size)
            evaluate(new_cell, cells, d_attr, w_attr, h_rep, w_rep)          
            best = cell if cell[:cost] < best[:cost]
            break if new_cell[:fitness] < cell[:fitness]
            cell = new_cell
          end
          moved_cells << cell
        end
        # TODO reproduce
      end
      # TODO elimination-dispersal
    end
    
    puts " >iteration=#{l}, fitness=#{best[:fitness]}, cost=#{best[:cost]}"
  end

  return best
end

if __FILE__ == $0
  problem_size = 3
  search_space = Array.new(problem_size) {|i| [-5, 5]}

  pop_size = 50
  d_attr = 0.1
  w_attr = 0.2 
  h_rep = d_attr
  w_rep = 10
  
  step_size = 0.1
  elim_disp_steps = 50
  repro_steps = 3
  chem_steps = 5
  swim_length = 10

  best = search(problem_size, search_space, pop_size, elim_disp_steps, repro_steps, chem_steps, swim_length, step_size, d_attr, w_attr, h_rep, w_rep)
  puts "done! Solution: f=#{best[:cost]}, s=#{best[:vector].inspect}"
end