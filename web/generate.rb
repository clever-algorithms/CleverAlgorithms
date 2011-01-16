# Generate the static content for the webpage

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2011 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

OUTPUT_DIR = "docs"

def create_directory(name)
  Dir.mkdir(name) unless File.directory?(name)
end


def get_all_data_lines(filename)
  raw = IO.readlines(filename)  
  # strip comments
  lines, gotdata = [], false
  raw.each do |line| 
    line = line.strip
    next if !gotdata and (line.empty? or line.nil?)
    next if !line.empty? and line[0].chr == '%'
    lines << line
    gotdata = true
  end
  puts " > loaded #{lines.size} lines from #{raw.size-lines.size} raw lines from #{filename}"
  return lines
end

def get_data_in_brackets(line)
  i,j = line.index("{")+1, line.rindex("}")
  return line[i...j]
end

# state machine for processing sections, subsections, subsubsections
def general_process_file(lines)
  data = []
  sec, subsec, subsubsec = false, false, false
  lines.each do |line|
    if line.start_with?("\\section")
      sec, subsec, subsubsec = true, false, false
      node = {}
      node[:section] = get_data_in_brackets(line)
      node[:content] = []
      data << node
    elsif line.start_with?("\\subsection")
      subsec, subsubsec = true, false
      node = {}
      node[:subsec] = get_data_in_brackets(line)
      node[:content] = []
      data.last[:content] << node
    elsif line.start_with?("\\subsubsection")
      subsubsec = true
      node = {}
      node[:subsubsec] = get_data_in_brackets(line)
      node[:content] = []
      data.last[:content].last[:content] << node      
    else
      # we just have a line
      if subsubsec
        data.last[:content].last[:content].last[:content] << line
      elsif subsec
        data.last[:content].last[:content] << line
      elsif sec
        data.last[:content] << line
      else
        raise "got line and not in section: #{line}"
      end
    end
  end
  return data
end



# lazy algorithm processing
def process_algorithm(filename)  
  lines = get_all_data_lines(filename)
  processed = general_process_file(lines)  
  data = {}  
  # basics
  data[:name] = processed.first[:section]
  processed.first[:content].each do |element|
    break if !element.kind_of?(String)
    data[:other_names] = get_data_in_brackets(element) if element.start_with?("\\emph")
  end 
  raise "could not find name" if data[:name].nil?  
  raise "could not find other names" if data[:other_names].nil?
  # expect a series of subsections
  processed.first[:content].each do |node|
    next if !node.kind_of?(Hash)
    if node[:subsec] == "Taxonomy"    
      data[:taxonomy] = node[:content]
    else
      raise "Unknown subsection #{node[:subsec]}"
    end
  end
  
  puts data.inspect
  puts " > successfull processed: #{data[:name]}"
  return data
end


if __FILE__ == $0
  # create dir
  create_directory(OUTPUT_DIR)
  
  # test for a single algorithm
  process_algorithm("../book/a_evolution/differential_evolution.tex")
  
end