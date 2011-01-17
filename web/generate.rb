# Generate the static content for the webpage

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2011 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

OUTPUT_DIR = "docs"

def create_directory(name)
  Dir.mkdir(name) unless File.directory?(name)
end

def starts_with?(data, string)
  # =~ m/^He/
  # =~ m/\AH/
  # at the moment will match on the whole string (lame)
  return data =~ /#{Regexp.escape(string)}/
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
    if starts_with?(line, "\\section")
      sec, subsec, subsubsec = true, false, false
      node = {}
      node[:section] = get_data_in_brackets(line)
      node[:content] = []
      data << node
    elsif starts_with?(line, "\\subsection")
      subsec, subsubsec = true, false
      node = {}
      node[:subsec] = get_data_in_brackets(line)
      node[:content] = []
      data.last[:content] << node
    elsif starts_with?(line, "\\subsubsection")
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

def add_line(s, line)
  s << "#{line}\n"
end

def replace_citations(s)
  return s.gsub(/\\cite\{([^}]+)\}/) do |elem| 
    x = elem[6...-1]
    "[<a href='\##{x}'>#{x}</a>]"
  end
end

# TODO replace refs to other algorithms with links
# TODO replace refs to listings with less text
def to_text_content(data)
  s = ""
  # state machine for building paragraphs  
  out = true
  data.each do |line|
    if line.empty?
      s << "</p>\n" if !out
      out = true
    else 
      if out
        s << "<p>" 
        out = false
      end
      s << "#{line}\n"
    end
  end
  s << "</p>\n" if !out
  s = replace_citations(s)
  return s
end

# TODO process the procedure
# TODO process the code listing
# TODO generate a biblography
def html_for_algortihm(data)
  s = ""
  # name
  add_line(s, "<h1>#{data[:name]}</h1>")
  add_line(s, "<emph>#{data[:other_names]}</emph>")
  # taxonomy
  add_line(s, "<h2>Taxonomy</h2>")
  add_line(s, to_text_content(data[:taxonomy]))
  # strategy
  add_line(s, "<h2>Strategy</h2>")
  add_line(s, to_text_content(data[:strategy]))
  # metaphor
  if !data[:metaphor].nil?
    add_line(s, "<h2>Metaphor</h2>")
    add_line(s, to_text_content(data[:metaphor]))  
  end
  # procedure
  add_line(s, "<h2>Procedure</h2>")
  add_line(s, to_text_content(data[:procedure]))
  # code
  add_line(s, "<h2>Code Listing</h2>")
  add_line(s, to_text_content(data[:code]))  
  # heuristics
  add_line(s, "<h2>Heuristics</h2>")
  add_line(s, "<ul>")
  data[:heuristics].each do |heuristic|
    add_line(s, "<li>#{heuristic}</li>")
  end
  add_line(s, "</ul>")
  # references
  add_line(s, "<h2>References</h2>")
  add_line(s, "<h3>Primary Sources</h3>")
  add_line(s, to_text_content(data[:refs][:primary]))  
  add_line(s, "<h3>Learn More</h3>")
  add_line(s, to_text_content(data[:refs][:secondary]))  
  return s
end

def write_algorithm(data, filename)
  html = html_for_algortihm(data)
  File.open(filename, 'w') {|f| f.write(html) }
  puts " > successfully wrote algorithm '#{data[:name]}' to: #{filename}"
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
    data[:other_names] = get_data_in_brackets(element) if starts_with?(element, "\\emph")
  end 
  raise "could not find name" if data[:name].nil?
  raise "could not find other names" if data[:other_names].nil?
  # expect a series of subsections
  text_sections = ["Taxonomy", "Strategy", "Metaphor", "Procedure", "Code Listing"]
  processed.first[:content].each do |node|
    next if !node.kind_of?(Hash)
    # text
    if text_sections.include?(node[:subsec])    
      data[:taxonomy] = node[:content] if node[:subsec] == "Taxonomy"
      data[:strategy] = node[:content] if node[:subsec] == "Strategy"
      data[:metaphor] = node[:content] if node[:subsec] == "Metaphor"
      data[:procedure] = node[:content] if node[:subsec] == "Procedure"
      data[:code] = node[:content] if node[:subsec] == "Code Listing"
    # heuristics
    elsif node[:subsec] == "Heuristics"
      heuristics = []
      node[:content].each do |element|
        next if element.empty?
        next if element.include?("\\begin{itemize}")
        next if element.include?("\\end{itemize}")
        heuristics << element.gsub("\\item", "")
      end
      data[:heuristics] = heuristics 
    # references
    elsif node[:subsec] == "References"
      refs = {}
      node[:content].each do |element|
        next if !element.kind_of?(Hash)
        if element[:subsubsec] == "Primary Sources"
          refs[:primary] = element[:content]
        elsif element[:subsubsec] == "Learn More"
          refs[:secondary] = element[:content]
        end
      end
      data[:refs] = refs
    else
      raise "Unknown subsection #{node[:subsec]}"
    end
  end
  puts " > successfull processed: #{data[:name]}"
  return data
end


if __FILE__ == $0
  # create dir
  create_directory(OUTPUT_DIR)
  
  # test for a single algorithm
  data = process_algorithm("../book/a_evolution/differential_evolution.tex")
  write_algorithm(data, "#{OUTPUT_DIR}/test.html")
  
end
