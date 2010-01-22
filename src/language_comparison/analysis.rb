# Genetic Algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

FILES = ["genetic_algorithm.py", "genetic_algorithm.pl", "genetic_algorithm.rb", "genetic_algorithm.lua"]
OFFSET = 7



def process_file(name)
  lines = IO.readlines(name)
  # skip
  lines = lines[OFFSET-1, lines.length-1]
  
  total_chars = 0
  total_lines = lines.length
  
  lines.each do |line|
    total_chars += line.strip.size
  end

  puts "--------------------------"
  puts "Report: #{name}"
  puts "lines:        #{total_lines}"
  puts "chars:        #{total_chars}"
  puts "avg per line: #{(total_chars.to_f/total_lines.to_f)}"
end

FILES.each{|name| process_file(name)}
