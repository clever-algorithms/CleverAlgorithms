# Generate the static content for the webpage
# just a big collection of hacks

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2011 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require 'bibtex'


OUTPUT_DIR = "docs"
BIBTEX_FILE = "../workspace/bibtex.bib"

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
#  puts " > loaded #{lines.size} lines from #{raw.size-lines.size} raw lines from #{filename}"
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
    # extract the content between {}    
    content = elem[6...-1]
    s = ""
    # process, because there could be multiple defined
    content.split(","). each do |citation|
       x = citation.strip
       s << "[<a href='\##{x}'>#{x}</a>] "
    end
    s
  end
end

# TODO look for all examples in the output and make sure they read well
def replace_listings(s)
  # listings  
  s = s.gsub(/Algorithm\~\\ref\{([^}]+)\}/) do |elem|
    "The following listing"
  end
  # algorithms
  s = s.gsub(/Listing\~\\ref\{([^}]+)\}/) do |elem|
    "The following algorithm"
  end
  return s
end

def replace_texttt(s)
  return s.gsub(/\\texttt\{([^}]+)\}/) do |elem|
    "<code>#{elem[8...-1]}</code>"
  end
end

def remove_section_refs(s)
  # remove section refs
  s = s.gsub(/Section\~\\ref\{([^}]+)\}/) {|e| ""}
  # some section refs have brackets around them, remove the brackets left
  s = s.gsub(" ()") {|e| ""} # don't want floating commas
  s = s.gsub("()") {|e| ""}
  return s
end

def remove_hyph_suggestions(s)
  return s.gsub("\\-") {|e| ""}
end

# create the pretty print
# http://code.google.com/p/google-code-prettify/
# http://google-code-prettify.googlecode.com/svn/trunk/README.html
def pretty_print_code_listing(code_listing_line)
  # get the file
  filename = get_data_in_brackets(code_listing_line)
  # get the caption
  parts = code_listing_line.split(",")
  raise "Caption not where expected" if !starts_with?(parts[2], "caption")
  caption = parts[2][(parts[2].index("=")+1)..-1]
  raw = IO.readlines(filename)
  raw.each_with_index {|r,i| raw[i]=r.rstrip}
  s = ""
  add_line(s, "<pre class='prettyprint lang-ruby'>")
  add_line(s, raw[6..-1].join("\n"))
  add_line(s, "</pre>")
  add_line(s, "<div>#{caption}</div>")
  return s
end

def is_code_listing?(line)
  return starts_with?(line, "\\lstinputlisting[firstline=")
end

# TODO add download link for source code (github? local?)
# create the content and pretty print
def prepare_code_listing(lines)
  text = []
  code_listing = nil
  lines.each do |line| 
    if is_code_listing?(line)
      code_listing =line
    else
      text << line
    end
  end
  raise "Could not locate code listing in lines #{lines.inspect}" if code_listing.nil?
  s = ""
  add_line(s, to_text_content(text)) 
  add_line(s, to_text_content(pretty_print_code_listing(code_listing)))
  return s
end

def no_pesudocode_msg(caption=nil)
  cap = (caption.nil?) ? "" : caption
  "<p><emph>#{cap} Please refer to the book for the pseudocode listing.</emph></p>\n"
end

def prepare_pseudocode(lines)
  text = []
  incode, caption = false, nil
  lines.each do |line| 
    if starts_with?(line, "\\begin{algorithm}")
      text << no_pesudocode_msg(caption) if incode
      incode = true
    else 
      if incode
        caption = get_data_in_brackets(line) if starts_with?(line, "\\caption{")
      else
        text << line
      end
    end
  end
  text << no_pesudocode_msg(caption) if incode
  return add_line("", to_text_content(text))
end

def collect_citations_for_page(data)
  stack, citations = [], []
  stack << data
  begin
    element = stack.shift
    element.each do |e| 
      if e.kind_of?(Hash)
        stack << e[:content]
      elsif e.kind_of?(String)
        next if e.nil? or e.empty?
        #e.scan(/\\cite\{([^}]+)\}/) do |c| 
        e.gsub(/\\cite\{([^}]+)\}/) do |c| 
          content = get_data_in_brackets(c)
          content.split(",").each do |cit|
            x = cit.strip
            citations << x if !citations.include?(x)
          end
          ""
        end        
      else 
        raise "got something unexpected in raw structure: #{e}"
      end
    end    
  end while !stack.empty?
  return citations.sort
end

# crunch text in bibtex fields to be human readable
def process_bibtex(datum)
  datum = datum.to_s
  datum = datum.gsub("--", "-")
  datum = datum.gsub(/\{([^}]+)\}/) {|c| c[1...-1] }
  datum = datum.gsub("~", " ")
  # replace \" and \' with nothing
  datum = datum.gsub("\\\"", "")
  datum = datum.gsub("\\\'", "")
  # replace \& with just &  
  datum = datum.gsub("\\&", "&")
  # replace \- with nothing (hypenation suggestions)
  datum = datum.gsub("\\-", "")
  return datum
end

# TODO construct google scholar url for titles
# assume ordering in http://en.wikipedia.org/wiki/BibTeX
def generate_bib_entry(entry)
  s = ""
  if entry.type == :book
    # author/editor, title, publisher, year
    s << "#{process_bibtex entry[:author]}, "
    s << "(#{process_bibtex entry[:editor]} eds), " if !entry[:editor].nil?
    s << "\"#{process_bibtex entry[:title]}\", "
    s << "#{process_bibtex entry[:publisher]}, " if !entry[:publisher].nil?
    s << "#{process_bibtex entry[:year]}."
  elsif entry.type == :article
    # author, title, journal, year
    s << "#{process_bibtex entry[:author]}, "
    s << "\"#{process_bibtex entry[:title]}\", "
    s << "#{process_bibtex entry[:journal]}, " if !entry[:journal].nil?
    s << "#{process_bibtex entry[:year]}."
  elsif entry.type == :inbook
    # author/editor, title, chapter/pages, publisher, year
    s << "#{process_bibtex entry[:author]}, " if !entry[:author].nil?
    s << "(#{process_bibtex entry[:editor]} eds), " if !entry[:editor].nil?
    s << "\"#{process_bibtex entry[:title]}\", "
    s << "#{process_bibtex entry[:chapter]}, " if !entry[:chapter].nil?
    s << "pages #{process_bibtex entry[:pages]}, " if !entry[:pages].nil?
    s << "#{process_bibtex entry[:publisher]}, " if !entry[:publisher].nil?
    s << "#{process_bibtex entry[:year]}."
  elsif entry.type == :techreport
    # author, title, institution, year
    s << "#{process_bibtex entry[:author]}, "
    s << "\"#{process_bibtex entry[:title]}\", "
    s << "#{process_bibtex entry[:institution]}, " if !entry[:institution].nil?
    s << "#{process_bibtex entry[:year]}."
  elsif entry.type == :inproceedings
    # author, title, booktitle, year
    s << "#{process_bibtex entry[:author]}, "
    s << "\"#{process_bibtex entry[:title]}\", "
    s << "#{process_bibtex entry[:booktitle]}, " if !entry[:booktitle].nil?
    s << "#{process_bibtex entry[:year]}."
  elsif entry.type == :phdthesis
    # author, title, school, year
    s << "#{process_bibtex entry[:author]}, "
    s << "\"#{process_bibtex entry[:title]}\", "
    s << "[PhD Thesis] "
    s << "#{process_bibtex entry[:school]}, " if !entry[:school].nil?
    s << "#{process_bibtex entry[:year]}."
  elsif entry.type == :mastersthesis
    # author, title, school, year
    s << "#{process_bibtex entry[:author]}, "
    s << "\"#{process_bibtex entry[:title]}\", "
    s << "[Masters Thesis] "
    s << "#{process_bibtex entry[:school]}, " if !entry[:school].nil?
    s << "#{process_bibtex entry[:year]}."
  elsif entry.type == :incollection
    # author, title, booktitle, year
    s << "#{process_bibtex entry[:author]}, "
    s << "\"#{process_bibtex entry[:title]}\", "
    s << "#{process_bibtex entry[:booktitle]}, " if !entry[:booktitle].nil?
    s << "#{process_bibtex entry[:year]}."
  else 
    raise "Unknown bibtex type: #{entry.type}"    
  end
  return s
end

# https://github.com/inukshuk/bibtex-ruby
def load_bibtex
  # parse
  return BibTeX::Bibliography.open(BIBTEX_FILE)  
end

def load_citations(citations, bib, data)
  hash = {}
  citations.each do |key|
    raise "No bibtex entry for key #{key}" if bib[key].nil?
    hash[key] = bib[key]
  end  
  return hash
end

# TODO better spacing between rows/cols (consider doing in css)
def prepare_bibliography(data, bib)
  citations = collect_citations_for_page(data)
  hash = load_citations(citations, bib, data)
  s = ""
  add_line(s, "<table>")
  citations.each do |c|
    add_line(s, " <tr valign=top>")
      add_line(s, " <td><a name='#{c}'>[#{c}]</a></td>")
      entry = generate_bib_entry(hash[c])
      add_line(s, " <td>#{entry}</td>")
    add_line(s, " </tr>")
  end  
  add_line(s, "</table>")
  return s
end

# TODO link to known algorithms (maybe)
def post_process_text(s)
    # citations
  s = replace_citations(s)
  # listings
  s = replace_listings(s)
  # texttt
  s = replace_texttt(s)
  # section refs
  s = remove_section_refs(s)
  # remove hypenation suggestions
  s = remove_hyph_suggestions(s)
  # replace \% with %
  s = s.gsub("\\%", "\%")
  # replace "\ " with a space
  s = s.gsub("\\ ", " ")
  # replace \" and \' with nothing
  s = s.gsub("\\\"", "")
  s = s.gsub("\\\'", "")
  return s
end

# TODO process ad hoc itemize in content (grammatical evolution)
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
  s = post_process_text(s)
  return s
end

def html_for_algortihm(data, bib)
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
  add_line(s, prepare_pseudocode(data[:procedure]))
  # code
  add_line(s, "<h2>Code Listing</h2>")
  add_line(s, prepare_code_listing(data[:code]))
  # heuristics
  add_line(s, "<h2>Heuristics</h2>")
  add_line(s, "<ul>")
  data[:heuristics].each do |heuristic|
    add_line(s, "<li>#{post_process_text heuristic}</li>")
  end
  add_line(s, "</ul>")
  # references
  add_line(s, "<h2>References</h2>")
  add_line(s, "<h3>Primary Sources</h3>")
  add_line(s, to_text_content(data[:refs][:primary]))  
  add_line(s, "<h3>Learn More</h3>")
  add_line(s, to_text_content(data[:refs][:secondary]))
  # Bibliography
  add_line(s, "<h2>Bibliography</h2>")  
  add_line(s, prepare_bibliography(data[:raw], bib))
  return s
end

def write_algorithm(data, bib, filename)
  html = html_for_algortihm(data, bib)
  File.open(filename, 'w') {|f| f.write(html) }
  puts " > successfully wrote algorithm '#{data[:name]}' to: #{filename}"
end

# lazy algorithm processing
def process_algorithm(filename)  
  data = {} 
  lines = get_all_data_lines(filename)
  processed = general_process_file(lines)  
  data[:raw] = processed 
  # basics
  data[:name] = processed.first[:section]
  processed.first[:content].each do |element|
    break if !element.kind_of?(String)
    data[:other_names] = get_data_in_brackets(element) if starts_with?(element, "\\emph")
  end 
  raise "could not find name" if data[:name].nil?
  raise "could not find other names" if data[:other_names].nil?
  # expect a series of subsections
  text_sections = ["Taxonomy", "Inspiration", "Strategy", "Metaphor", "Procedure", "Code Listing"]
  processed.first[:content].each do |node|
    next if !node.kind_of?(Hash)
    # text
    if text_sections.include?(node[:subsec])    
      data[:taxonomy] = node[:content] if node[:subsec] == "Taxonomy"
      data[:inspiration] = node[:content] if node[:subsec] == "Inspiration"
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
      raise "Unknown subsection #{node[:subsec]}, file=#{filename}"
    end
  end
#  puts " > successfull processed: #{data[:name]}"
  return data
end

# TODO process chapter overview
def build_algorithm_chapter(name, bib)
  dirname = OUTPUT_DIR + "/"+name
  create_directory(dirname)
  
  # process all algorithms for algorithm chapter
  source = "../book/a_"+name
  Dir.entries(source).each do |file|
    next if file == "." or file == ".."
    next if File.extname(file) != ".tex"
    # load and process the algorithm
    data = process_algorithm(source + "/" + file)
    # write the html for the algorithm
    write_algorithm(data, bib, "#{dirname}/#{file[0...-4]}.html")
  end
end


ALGORITHM_CHAPTERS = ["stochastic", "evolution", "physical", "probabilistic", "swarm", "immune", "neural"]

if __FILE__ == $0
  # create dir
  create_directory(OUTPUT_DIR)
  # load the bib 
  bib = load_bibtex()
  
  # process algorithm chapters
  ALGORITHM_CHAPTERS.each {|name| build_algorithm_chapter(name, bib) }
  
  #build_algorithm_chapter("neural", bib)
  
  # test for a single algorithm
#  data = process_algorithm("../book/a_stochastic/iterated_local_search.tex")
#  write_algorithm(data, bib, "#{OUTPUT_DIR}/test.html")
  
end
