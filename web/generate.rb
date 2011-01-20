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

# http://railsforum.com/viewtopic.php?id=10057
def starts_with?(data, prefix)
  return data[0...prefix.length] == prefix
end

# basic processing
def get_all_data_lines(filename)
  raw = IO.readlines(filename)  
  # strip comments
  lines, gotdata = [], false
  raw.each do |raw_line| 
    line = raw_line.strip
    next if !gotdata and (line.empty? or line.nil?)
    next if !line.empty? and starts_with?(line, "%")
    next if !line.empty? and starts_with?(line, "\\label")
    next if !line.empty? and starts_with?(line, "\\index")
    next if !line.empty? and starts_with?(line, "\\begin{bibunit}")
    next if !line.empty? and starts_with?(line, "\\end{bibunit}")
    next if !line.empty? and starts_with?(line, "\\renewcommand")
    next if !line.empty? and starts_with?(line, "\\putbib")
    next if !line.empty? and starts_with?(line, "\\vspace")    
    next if !line.empty? and line == "\\newpage" # just the newpage
    next if !line.empty? and starts_with?(line, "\\begin{flushleft}")
    next if !line.empty? and starts_with?(line, "\\begin{small}")
    next if !line.empty? and starts_with?(line, "\\end{flushleft}")
    next if !line.empty? and starts_with?(line, "\\end{small}")
    next if !line.empty? and starts_with?(line, "\\begin{flushright}")
    next if !line.empty? and starts_with?(line, "\\end{flushright}")
    lines << raw_line
    gotdata = true
  end
#  puts " > loaded #{lines.size} lines from #{raw.size-lines.size} raw lines from #{filename}"
  return lines
end

def get_data_in_brackets(line)
  i,j = line.index("{")+1, line.rindex("}")
  return line[i...j]
end

# lazy state machine for processing chapters (optional), sections, subsections, subsubsections
def general_process_file(lines)
  data = []
  chap, sec, subsec, subsubsec = false, false, false, false
  lines.each do |raw_line|
    line = raw_line.strip
    if starts_with?(line, "\\chapter")
      node = {}
      node[:chapter] = get_data_in_brackets(line)
      node[:content] = []
      data << node
      chap = true
    elsif starts_with?(line, "\\section")
      sec, subsec, subsubsec = true, false, false
      node = {}
      node[:section] = get_data_in_brackets(line)
      node[:content] = []      
      ((chap) ? data.last[:content] : data) << node
    elsif starts_with?(line, "\\subsection")
      subsec, subsubsec = true, false
      node = {}
      node[:subsec] = get_data_in_brackets(line)
      node[:content] = []
      # puts line
      # puts data.last[:content].inspect
      ((chap) ? data.last[:content].last[:content] : data.last[:content]) << node
    elsif starts_with?(line, "\\subsubsection")
      subsubsec = true
      node = {}
      node[:subsubsec] = get_data_in_brackets(line)
      node[:content] = []
      ((chap) ? data.last[:content].last[:content].last[:content] : data.last[:content].last[:content]) << node
    else
      # we just have a line (store the raw line)
      if subsubsec
        ((chap) ? data.last[:content].last[:content].last[:content].last[:content] : data.last[:content].last[:content].last[:content]) << raw_line
      elsif subsec
        ((chap) ? data.last[:content].last[:content].last[:content] : data.last[:content].last[:content]) << raw_line
      elsif sec
        ((chap) ? data.last[:content].last[:content] : data.last[:content]) << raw_line
      elsif chap
        data.last[:content] << raw_line
      else
        raise "got line and not in a known section type: #{line}"
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
       s << " [<a href='\##{x}'>#{x}</a>]"
    end
    s
  end
end

# TODO look for all examples in the output and make sure they read well
def replace_listings(s)
  # algorithms
  s = s.gsub(/Algorithm\~\\ref\{([^}]+)\}/) do |elem|
    "The following algorithm"
  end
  # listings  
  s = s.gsub(/Listing\~\\ref\{([^}]+)\}/) do |elem|
    "The following listing"
  end
  # tables (NOTE: the lower case) - used only in devising new algorithms
  s = s.gsub(/Table\~\\ref\{([^}]+)\}/) do |elem|
    "the following table" 
  end  
  # figure
  s = s.gsub(/Figure\~\\ref\{([^}]+)\}/) do |elem|
    "The following figure"
  end  
  return s
end

# custom refs
def replace_custom_refs(s)
  # Appendix~\ref{ch:appendix1}
  s = s.gsub("Appendix~\\ref{ch:appendix1}") do |elem|
    "<a href='appendix1.html'>Appendix A: Ruby: Quick-Start Guide</a>"
  end
  # Section~{subsec:nfl} in problem solving strategies
  s = s.gsub("Section~{subsec:nfl}") do |elem|
    "the <a href='../introduction.html'>Introduction</a>"
  end  
  return s
end

# TODO bug with the string \texttt{#\{\}} (appendix)
def replace_texttt(s)
  return s.gsub(/\\texttt\{([^}]+)\}/) do |elem|
    "<code>#{elem[8...-1]}</code>"
  end
end

def replace_emph(s)
  return s.gsub(/\\emph\{([^}]+)\}/) do |elem|
    "<em>#{elem[6...-1]}</em>"
  end
end

def replace_bf(s)
  return s.gsub(/\\textbf\{([^}]+)\}/) do |elem|
    "<strong>#{elem[8...-1]}</strong>"
  end
end

def replace_urls(s)
  return s.gsub(/\\url\{([^}]+)\}/) do |elem|
    content = elem[5...-1]
    "<a href='#{content}'>#{content}</a>"
  end
end

def replace_footnotes(s)
  return s.gsub(/\\footnote\{([^}]+)\}/) do |elem|
    " (#{elem[10...-1]})"
  end
end

def replace_paragraphs(s)
  return s.gsub(/\\paragraph\{([^}]+)\}/) do |elem|
    "<strong>#{elem[11...-1]}</strong>"
  end
end

def replace_markboth(s)
  return s.gsub(/\\markboth\{([^}]+)\}\{\}/) do |elem|
    ""
  end
end

# used in at least the intro
# the refs are relative - might cause problems in html in sub dirs
def replace_chapter_refs(s)
  # stochastic
  s = s.gsub(/Chapter\~\\ref\{ch:stochastic\}/) do |elem|
    "<a href='stochastic.html'>Stochastic Algorithms Chapter</a>"
  end
  # evolutionary
  s = s.gsub(/Chapter\~\\ref\{ch:evolutionary\}/) do |elem|
    "<a href='evolution.html'>Evolutionary Algorithms Chapter</a>"
  end
  # physical
  s = s.gsub(/Chapter\~\\ref\{ch:physical\}/) do |elem|
    "<a href='physical.html'>Physical Algorithms Chapter</a>"
  end    
  # probabilistic
  s = s.gsub(/Chapter\~\\ref\{ch:probabilistic\}/) do |elem|
    "<a href='probabilistic.html'>Probabilistic Algorithms Chapter</a>"
  end
  # swarm
  s = s.gsub(/Chapter\~\\ref\{ch:swarm\}/) do |elem|
    "<a href='swarm.html'>Swarm Algorithms Chapter</a>"
  end
  # immune
  s = s.gsub(/Chapter\~\\ref\{ch:immune\}/) do |elem|
    "<a href='immune.html'>Immune Algorithms Chapter</a>"
  end
  # neural
  s = s.gsub(/Chapter\~\\ref\{ch:neural\}/) do |elem|
    "<a href='neural.html'>Neural Algorithms Chapter</a>"
  end
  return s
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

def process_angle_brackets(s)
  s = s.gsub("<", "&lt;")
  s = s.gsub(">", "&gt;")
  return s
end

# TODO add download link for source code (github? local?)
# create the pretty print
# http://code.google.com/p/google-code-prettify/
# http://google-code-prettify.googlecode.com/svn/trunk/README.html
def final_pretty_code_listing(lines, caption=nil)
  # remove trailining white space
  lines.each_with_index {|r,i| lines[i]=r.rstrip}
  # make a string
  raw = lines.join("\n") 
  # pretty print does not like <> brackets
  raw = process_angle_brackets(raw)
  s = ""
  add_line(s, "<pre class='prettyprint lang-rb'>")
  add_line(s, raw)
  add_line(s, "</pre>")
  add_line(s, "<caption>#{caption}</caption>") if !caption.nil?
  #add_line(s, "<a href="">Download</a>")
  return s
end

def pretty_print_code_listing(code_listing_line)
  # get the file
  filename = get_data_in_brackets(code_listing_line)
  # get the caption
  parts = code_listing_line.split(",")
  raise "Caption not where expected" if !starts_with?(parts[2], "caption")
  caption = parts[2][(parts[2].index("=")+1)..-1]
  raw = IO.readlines(filename)  
  # trip top 7 lines
  raw = raw[6..-1]
  s = final_pretty_code_listing(raw, caption)
  return s
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

# collect all 'sub-pages' in a chapter overview
def collect_subpages_for_page(data)
  stack, subpages = [], []
  stack << data
  begin
    element = stack.shift
    element.each do |e| 
      if e.kind_of?(Hash)
        stack << e[:content]
      elsif e.kind_of?(String)
        next if e.nil? or e.empty?
        #e.scan(/\\newpage\\begin{bibunit}\\input{/) do |c| 
        e.gsub(/\\newpage\\begin\{bibunit\}\\input\{/) do |c| 
          filename = e.match(/\\input\{([^}]+)\}/).to_s
          subpages << filename[(filename.index("/")+1)...-1]
          ""
        end        
      else 
        raise "got something unexpected in raw structure: #{e}"
      end
    end    
  end while !stack.empty?
  return subpages
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

# TODO support no author, but has editors
# TODO display authors consistantly (F. Lastname when stored as Lastname, F.)
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
  elsif entry.type == :conference
    # author, title, booktitle, year
    s << "#{process_bibtex entry[:author]}, "
    s << "\"#{process_bibtex entry[:title]}\", "
    s << "#{process_bibtex entry[:booktitle]}, " if !entry[:booktitle].nil?
    s << "#{process_bibtex entry[:year]}."
  elsif entry.type == :unpublished
    # author, title
    s << "#{process_bibtex entry[:author]}, "
    s << "\"#{process_bibtex entry[:title]}\", "
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

def process_table(lines)
  s = ""
  add_line(s, "<table border='1'>")
  
  lines.each do |line| 
    next if starts_with?(line, "\\centering")
    next if starts_with?(line, "\\begin{tabularx}")
    next if starts_with?(line, "\\end{tabularx}")
    next if starts_with?(line, "\\toprule")
    next if starts_with?(line, "\\bottomrule")
    next if starts_with?(line, "\\midrule")
    
    if starts_with?(line.strip, "\\caption")
      add_line(s, "<caption align=bottom>#{get_data_in_brackets(line)}</caption>")
    else
      lines = line.gsub("\\\\", "") # remove \\ on the end
      add_line(s, "<tr>")
      line.split("&").each do |td|
        add_line(s, "<td>#{td.strip}</td>") # do we need to process this text? - na
      end
      add_line(s, "</tr>")
    end
  end
  
  add_line(s, "</table>")
  return s
end

def process_align(lines)
  s = lines.join(" ")
  # remove &
  s = s.gsub("&", "")
  # remove \\
  s = s.gsub("\\\\", "")
  return "$#{s}$" # math!
end

def process_equation(lines)
  s = lines.join(" ")  
  return "$#{s}$" # math!
end

# TODO assume images in rails friendly location
def process_figure(lines)
  caption, filename = nil, nil
  lines.each do |line|
    caption = get_data_in_brackets(line) if starts_with?(line.strip, "\\caption")
    if starts_with?(line.strip, "\\input") or starts_with?(line.strip, "\\includegraphics")
      filename = get_data_in_brackets(line) 
    end
    break if !caption.nil? and !filename.nil?
  end
  raise "Could not locate data caption=#{caption}, filename=#{filename}" if filename.nil? or caption.nil?
  #png = "../book/" + filename + ".png"
  just_file = filename[(filename.index('/')+1)...-1]
  s = ""
  add_line(s, "<img src='#{just_file}.png' align='middle' alt='#{caption}'>")
  add_line(s, "<br />")
  add_line(s, "<caption>#{caption}</caption>")
  
  return s
end

# TODO link to known algorithms (maybe)
# be careful - even code goes through this!
def post_process_text(s)
  # citations
  s = replace_citations(s)
  # listings, algorithms, tables
  s = replace_listings(s)
  # custom 
  s = replace_custom_refs(s)
  # texttt
  s = replace_texttt(s)
  # emph
  s = replace_emph(s)
  # textbf
  s = replace_bf(s)
  # urls
  s = replace_urls(s)
  # footnotes
  s = replace_footnotes(s)
  # paragrams
  s = replace_paragraphs(s)
  # chapter refs
  s = replace_chapter_refs(s)
  # section refs
  s = remove_section_refs(s)
  # replace markboth with nothing
  s = replace_markboth(s)
  # remove hypenation suggestions
  s = remove_hyph_suggestions(s)
  # replace \% with %
  s = s.gsub("\\%", "\%")
  # replace "\ " with a space
  s = s.gsub("\\ ", " ")
  # replace \" and \' with nothing
  s = s.gsub("\\\"", "")
  s = s.gsub("\\\'", "")
  # replace ~ with space
  s = s.gsub("~", " ")
  # replace \$ with $ (testing algorithms)
  s = s.gsub("\\$", "$")
  # replace \_ with _ (testing algorithms)
  s = s.gsub("\\_", "_")  
  # replace \# with # (appendix)
  s = s.gsub("\\#", "#")
  # replace \{ with { (appendix)
  s = s.gsub("\\{", "{")
  # replace \} with } (appendix)
  s = s.gsub("\\}", "}") 
  # replace \\ with <br /> (appendix)
  s = s.gsub("\\\\", "<br />") 
  return s
end

# from visualization chapter and appendix
def process_code_listing(lines)
  # extract caption
  caption = nil
  # no caption for listings in appendix
  if !lines.first.index(",").nil?
    raise "error [#{lines.first.index(",")}] [#{lines.first}]" if lines.first.split(",").size != 2
    raise "error" if lines.first.split(",").first.split("=").size != 2
    caption = lines.first.split(",").first.split("=")[1]  
  end
  # remove start and end
  lines = lines[1..-1]
  # pretty print  
  return final_pretty_code_listing(lines, caption)
end

# TODO <> inside math in grammatical evolution (consider making non-math and texttt)
# TODO array equations (Hopfield)
# TODO display pseudocode algorithm (all algorithms)
def to_text_content(data)
  s = ""
  # state machine for building paragraphs/items/algorithms
  out, in_items, in_algorithm, in_listing, in_enum = true, false, false, false, false
  in_table, in_align, in_equation, in_figure = false, false, false, false
  algorithm_caption = nil
  table_collection, align_collection, equation_collection, figure_collection = [], [], [], []
  listing_collection = []
  data.each do |raw_line|
    # STRIP white space
    line = raw_line.strip
    if line.empty? and !in_items # end paragraph
      s << "</p>\n" if !out
      out = true
    elsif starts_with?(line, "\\lstinputlisting[firstline=") # listing file
      s << pretty_print_code_listing(line)
    elsif starts_with?(line, "\\begin{itemize}") # start itemize
      s << "</p>\n" if !out # end paragraph
      add_line(s, "<ul>")
      out, in_items = true, true
    elsif starts_with?(line, "\\end{itemize}")  # end itemize
      out, in_items = true, false
      add_line(s, "</ul>")
    elsif starts_with?(line, "\\begin{algorithm}") # start pseudocode
      s << "</p>\n" if !out # end paragraph
      out, in_algorithm = true, true
    elsif starts_with?(line, "\\end{algorithm}") # end pseudocode
      out, in_algorithm = true, false
      raise "Could not find caption for pseudocode" if algorithm_caption.nil?
      add_line(s, "<p>")
      add_line(s, "<pre prettyprint'>Please refer to the book for the pseudocode.</pre>")
      add_line(s, algorithm_caption)
      add_line(s, "<p>")
      algorithm_caption = nil
    elsif starts_with?(line, "\\begin{lstlisting}") # start listing
      s << "</p>\n" if !out # end paragraph
      out, in_listing = true, true    
      listing_collection << raw_line # unstripped
    elsif starts_with?(line, "\\end{lstlisting}") # end listing
      out, in_listing = true, false
      add_line(s, process_code_listing(listing_collection))
      listing_collection = []
    elsif starts_with?(line, "\\begin{enumerate}") # start enumerate
      s << "</p>\n" if !out # end paragraph
      add_line(s, "<ol>")
      out, in_enum = true, true
    elsif starts_with?(line, "\\end{enumerate}")  # end enumerate
      out, in_enum = true, false
      add_line(s, "</ol>")
    elsif starts_with?(line, "\\begin{align") # start align
      s << "</p>\n" if !out # end paragraph
      out, in_align = true, true
    elsif starts_with?(line, "\\end{align")  # end align
      out, in_align = true, false
      add_line(s, process_align(align_collection))
      align_collection = []      
    elsif starts_with?(line, "\\begin{equation") # start equation
      s << "</p>\n" if !out # end paragraph
      out, in_equation = true, true
    elsif starts_with?(line, "\\end{equation")  # end equation
      out, in_equation = true, false
      add_line(s, process_equation(equation_collection))
      equation_collection = []           
    elsif starts_with?(line, "\\begin{figure}") # start figure
      s << "</p>\n" if !out # end paragraph
      out, in_figure = true, true
    elsif starts_with?(line, "\\end{figure}")  # end figure
      out, in_figure = true, false
      add_line(s, process_figure(figure_collection))
      figure_collection = []       
    elsif starts_with?(line, "\\begin{table}") # start table
      s << "</p>\n" if !out # end paragraph
      out, in_table = true, true
    elsif starts_with?(line, "\\end{table}")  # end table
      out, in_table = true, false
      add_line(s, process_table(table_collection))
      table_collection = []      
    else 
      if out
        if in_items
          add_line(s, "<li>#{post_process_text(line).gsub("\\item", "")}</li>")
        elsif in_enum
          add_line(s, "<li>#{post_process_text(line).gsub("\\item", "")}</li>")
        elsif in_algorithm
          # ignore (for now)
          algorithm_caption = get_data_in_brackets(line) if starts_with?(line, "\\caption{")
        elsif in_listing
          listing_collection << raw_line # unstripped
        elsif in_table
          table_collection << line
        elsif in_align
          align_collection << line
        elsif in_equation
          equation_collection << line
        elsif in_figure
          figure_collection << line
        else
          add_line(s, "<p>"+line)
          out = false
        end
      else
        add_line(s, line)
      end   
    end
  end
  add_line(s, "</p>") if !out
  s = post_process_text(s)
  return s
end

def get_algorithm_name(filename)
  lines = get_all_data_lines(filename)
  processed = general_process_file(lines)  
  return processed.last[:section]
end

# for intro chapter (at least)
def header_for_hash(hash, has_chapter)
  if !has_chapter
    return "<h1>#{post_process_text hash[:section]}</h1>" if !hash[:section].nil?
    return "<h2>#{post_process_text hash[:subsec]}</h2>" if !hash[:subsec].nil?
    return "<h3>#{post_process_text hash[:subsubsec]}</h3>" if !hash[:subsubsec].nil?  
  end
  return "<h1>#{post_process_text hash[:chapter]}</h1>" if !hash[:chapter].nil?
  return "<h2>#{post_process_text hash[:section]}</h2>" if !hash[:section].nil?
  return "<h3>#{post_process_text hash[:subsec]}</h3>" if !hash[:subsec].nil?
  return "<h4>#{post_process_text hash[:subsubsec]}</h4>" if !hash[:subsubsec].nil?
end

def recursive_html_for_chapter(data, has_chapter=true)
  s, lines = "", []
  data.each do |element|
    # some kind of sub-section
    if element.kind_of?(Hash) 
      # purge any collected lines
      if !lines.empty?
        add_line(s, to_text_content(lines))
        lines = []
      end  
      # heading
      add_line(s, header_for_hash(element, has_chapter))
      # recursively process content
      add_line(s, recursive_html_for_chapter(element[:content], has_chapter))
    else
      # always ignore some lines at this point
      next if starts_with?(element, "\\newpage\\begin{bibunit}\\input{")
      next if starts_with?(element, "\\addcontentsline{toc}")
      # collect lines (so we can process them in batch)
      lines << element
    end
  end
  # check for any left over lines (this 'section' is all lines)
  add_line(s, to_text_content(lines)) if !lines.empty?
  return s
end


def breadcrumb(parent=nil)
  s = ""  
  add_line(s, "<div class='breadcrumb'>") 
  if parent.nil?  
    add_line(s, "<a href='index.html'>Contents</a>")
  else
    add_line(s, "<a href='../index.html'>Contents</a>")
    add_line(s, "&gt;&gt; <a href='../#{parent[:link]}.html'>#{parent[:name]}</a>")
  end
  add_line(s, "</div>") 
  return s
end

def html_for_algorithm(data, bib, parent)
  s = ""
  s << breadcrumb(parent)
  s << recursive_html_for_chapter(data, false)
  # bib
  add_line(s, "<h2>Bibliography</h2>")  
  add_line(s, prepare_bibliography(data, bib))
  return s
end

# TODO list algorithms before 'extensions'
def html_for_chapter_overview(name, data, source, bib, subsecname)
  s = ""
  s << breadcrumb()
  s << recursive_html_for_chapter(data)
  # Algorithms
  add_line(s, "<h3>#{subsecname}</h3>")
  add_line(s, "<ul>")
  algos = collect_subpages_for_page(data)
  algos.each do |filename|
    # super lazy at getting algorithm names - consider a better process
    algo_name = get_algorithm_name(source+"/"+filename+".tex")
    add_line(s, "<li><a href='#{name}/#{filename}.html'>#{algo_name}</a></li>")
  end
  add_line(s, "</ul>")
  # Bibliography
  # lazy check - some chapter overviews do not have a bib!
  citations = collect_citations_for_page(data)
  if !citations.empty?
    add_line(s, "<h3>Bibliography</h3>")  
    add_line(s, prepare_bibliography(data, bib))
  end
  return s
end

def process_chapter_overview(name, bib, source, subsecname="Algorithms")
  lines = get_all_data_lines("../book/c_#{name}.tex")
  processed = general_process_file(lines)
  html = html_for_chapter_overview(name, processed, source, bib, subsecname)
  filename = OUTPUT_DIR + "/"+name+".html"
  File.open(filename, 'w') {|f| f.write(html) }
  puts " > successfully wrote algorithm chapter overview '#{name}' to: #{filename}"
  return {:link=>name, :name=>processed.last[:chapter]}
end

def build_algorithm_chapter(name, bib)
  dirname = OUTPUT_DIR + "/"+name
  create_directory(dirname)
  source = "../book/a_"+name
  # process chapter overview
  parent = process_chapter_overview(name, bib, source)  
  # process all algorithms for algorithm chapter  
  Dir.entries(source).each do |file|
    next if file == "." or file == ".."
    next if File.extname(file) != ".tex"
    # load and process the algorithm
    lines = get_all_data_lines(source + "/" + file)
    processed = general_process_file(lines)
    # write the html for the algorithm
    html = html_for_algorithm(processed, bib, parent)
    filename = "#{dirname}/#{file[0...-4]}.html"
    File.open(filename, 'w') {|f| f.write(html) }
    puts " > successfully wrote algorithm '#{processed.first[:section]}' to: #{filename}"
  end
end

def html_for_chapter(data, bib)
  s = ""
  s << breadcrumb()
  # process section
  s << recursive_html_for_chapter(data)  
  # Bibliography
  # lazy check - some chapter overviews do not have a bib!
  citations = collect_citations_for_page(data)
  if !citations.empty?
    add_line(s, "<h2>Bibliography</h2>")  
    add_line(s, prepare_bibliography(data, bib))
  end
  return s
end

def build_chapter(bib, name)
  lines = get_all_data_lines("../book/#{name}.tex")
  processed = general_process_file(lines)
  html = html_for_chapter(processed, bib)
  output = name[(name.index('_')+1)..-1]
  filename = OUTPUT_DIR + "/"+output+".html"
  File.open(filename, 'w') {|f| f.write(html) }
  puts " > successfully wrote chapter '#{name}' to: #{filename}"
end

def build_advanced_chapter(bib, name="advanced")
  dirname = OUTPUT_DIR + "/"+name
  create_directory(dirname)
  source = "../book/c_"+name
  # process chapter overview
  parent = process_chapter_overview(name, bib, source, "Advanced Topics")  
  # process all algorithms for algorithm chapter  
  Dir.entries(source).each do |file|
    next if file == "." or file == ".."
    next if File.extname(file) != ".tex"
    # load and process the algorithm
    lines = get_all_data_lines(source + "/" + file)
    processed = general_process_file(lines)
    # html for section
    html = html_for_algorithm(processed, bib, parent)
    filename = "#{dirname}/#{file[0...-4]}.html"
    File.open(filename, 'w') {|f| f.write(html) }
    puts " > successfully wrote topic '#{processed.first[:section]}' to: #{filename}"
  end
end

def build_appendix(bib, name="appendix1")
  lines = get_all_data_lines("../book/b_#{name}.tex")
  processed = general_process_file(lines)
  html = html_for_chapter(processed, bib)
  filename = OUTPUT_DIR + "/"+name+".html"
  File.open(filename, 'w') {|f| f.write(html) }
  puts " > successfully wrote appendix '#{name}' to: #{filename}"
end

def create_toc_html(algorithms, frontmatter)
  s = ""
  # front matter
  add_line(s, "<ol>")
  frontmatter.each do |name|
    output = name[(name.index('_')+1)..-1]
    add_line(s, "<li><a href='#{output}.html'>#{output}</a></li>")
  end
  # intro
  add_line(s, "<li><strong>Background</strong></li>")
  add_line(s, "<ol>")
  add_line(s, "<li><a href='introduction.html'>Introduction</a></li>")
  add_line(s, "</ol>")
  # algorithms
  add_line(s, "<li><strong>Algorithms</strong></li>")
  add_line(s, "<ol>")
  algorithms.each do |name|
    lines = get_all_data_lines("../book/c_#{name}.tex")
    data = general_process_file(lines)  
    add_line(s, "<li><a href='#{name}.html'>#{data.last[:chapter]}</a></li>")
    algos = collect_subpages_for_page(data)
    add_line(s, "<ol>")
    algos.each do |filename|
      # super lazy at getting algorithm names - consider a better process
      algo_name = get_algorithm_name("../book/a_#{name}/"+filename+".tex")
      add_line(s, "<li><a href='#{name}/#{filename}.html'>#{algo_name}</a></li>")
    end
    add_line(s, "</ol>")
  end
  add_line(s, "</ol>")
  # advanced
  add_line(s, "<li><strong>Extensions</strong></li>")  
  begin
    add_line(s, "<ol>")
    lines = get_all_data_lines("../book/c_advanced.tex")
    data = general_process_file(lines)  
    add_line(s, "<li><a href='advanced.html'>#{data.last[:chapter]}</a></li>")
    algos = collect_subpages_for_page(data)
    add_line(s, "<ol>")
    algos.each do |filename|
      # super lazy at getting algorithm names - consider a better process
      algo_name = get_algorithm_name("../book/c_advanced/"+filename+".tex")
      add_line(s, "<li><a href='advanced/#{filename}.html'>#{algo_name}</a></li>")
    end
    add_line(s, "</ol>")      
    add_line(s, "</ol>")
  end
  # appendix
  add_line(s, "<li><a href='appendix1.html'>Appendix A - Ruby: Quick-Start Guide</a></li>")
  add_line(s, "</ol>")
  return s
end

def build_toc(algorithms, frontmatter)
  html = create_toc_html(algorithms, frontmatter)
  filename = OUTPUT_DIR + "/index.html"
  File.open(filename, 'w') {|f| f.write(html) }
  puts " > successfully wrote toc to: #{filename}"
end

# these are ordered
ALGORITHM_CHAPTERS = ["stochastic", "evolution", "physical", "probabilistic", "swarm", "immune", "neural"]
# TODO add "f_copyright"
FRONT_MATTER = ["f_foreword", "f_preface", "f_acknowledgments"]

if __FILE__ == $0
  # create dir
  create_directory(OUTPUT_DIR)
  # load the bib 
  bib = load_bibtex()
  # TOC
  build_toc(ALGORITHM_CHAPTERS, FRONT_MATTER)
  # front matter
  FRONT_MATTER.each {|name| build_chapter(bib, name) }
  # introduction chapter
  build_chapter(bib, "c_introduction")  
  # process algorithm chapters
  ALGORITHM_CHAPTERS.each {|name| build_algorithm_chapter(name, bib) }
  # advaced topics 
  build_advanced_chapter(bib)  
  # appendix
  build_appendix(bib) 
end
