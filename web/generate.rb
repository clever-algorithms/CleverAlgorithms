# Generate the static content for the webpage
# just a big collection of hacks - never do this - use a real lexer/parser

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2011 Jason Brownlee. Some Rights Reserved.
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

require File.expand_path(File.dirname(__FILE__)) + '/bibtex'


OUTPUT_DIR = "build/web"
BIBTEX_FILE = "book/bibtex.bib"

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
    next if !line.empty? and starts_with?(line, "\\start{small}")
    next if !line.empty? and starts_with?(line, "\\end{small}")
    lines << raw_line
    gotdata = true
  end
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

def process_angle_brackets_and_ampersands(s)
  s = s.gsub("&", "&amp;")
  s = s.gsub("<", "&lt;")
  s = s.gsub(">", "&gt;")
  return s
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

def replace_listings(s)
  # algorithms
  s = s.gsub(/Algorithm\~\\ref\{([^}]+)\}/) do |elem|
    "Algorithm (below)"
  end
  # listings
  s = s.gsub(/Listing\~\\ref\{([^}]+)\}/) do |elem|
    "Listing (below)"
  end
  # tables (NOTE: the lower case) - used only in devising new algorithms
  s = s.gsub(/Table\~\\ref\{([^}]+)\}/) do |elem|
    "Table (below)"
  end
  # figure
  s = s.gsub(/Figure\~\\ref\{([^}]+)\}/) do |elem|
    "Figure (below)"
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

# maybe see: http://stackoverflow.com/questions/3594325/find-matching-bracket-with-regex
# this func does endspecial handing of << >> for grammatical evolution
def replace_texttt(s)
  return s.gsub(/\\texttt\{([^}]+)\}/) do |elem|
    "<code>#{ process_angle_brackets_and_ampersands(elem[8...-1]) }</code>"
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

# http://www.w3schools.com/tags/ref_entities.asp
# http://webdesign.about.com/library/bl_htmlcodes.htm
# http://en.wikibooks.org/wiki/LaTeX/Accents
def character_processing(s)
  s = s.gsub("\\\"a", "&auml;") # a
  s = s.gsub("\\\"o", "&ouml;") # o
  s = s.gsub("\\\"u", "&uuml;") # u

  s = s.gsub("\\\'u", "&uacute;") # u
  s = s.gsub("\\\'e", "&eacute;") # e
  s = s.gsub("\\\'i", "&iacute;") # i
	s = s.gsub("\\\'c", "&#263;") # c

	# others
	s = s.gsub("\\v{u}", "&#365;") # u
	s = s.gsub("\\v{c}", "&#269;") # c

	s = s.gsub("\\c{c}", "&ccedil;") # c
	s = s.gsub("\\~{n}", "&ntilde;") # n (Larranaga does not work in latex atm)


  s = s.gsub("--", "&ndash;")
  s = s.gsub("\\&", "&amp;")
  s = s.gsub("\\@", "@")
  # replace `` and '' with quotes
  s = s.gsub("``", "&quot;")
  s = s.gsub("''", "&quot;")
  s = s.gsub("`", "'")

  return s
end

# the math hack in here just grabs all math before processing, then adds it back after.
# sucks i know
def post_process_text(s)
  # extract math
  math, arrays = [], []
  s.scan(/\$([^$]+)\$/) {|m| math << m } # $$
  s.scan(/\\\[([^$]+)\\\]/) {|m| arrays << m } #  \[ \]
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
  # umlats etc
  s = character_processing(s)
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
  # replace \\ with <br /> (appendix,  de)
  s = s.gsub("\\\\", "<br />")
  # replace \Latex with LaTex
  s = s.gsub("\\LaTeX", "LaTex")
  # replace \copyright with html copyright
  s = s.gsub("\\copyright", "&copy;")
  # replace \mybookdate\ with publication date 2011
  s = s.gsub("\\mybookdate", "2011")
  # replace \mybookauthor with the author ame
  s = s.gsub("\\mybookauthor", "Jason Brownlee")
  # replace \mybooktitle with the book title
  s = s.gsub("\\mybooktitle", "Clever Algorithms")
  # replace \mybooksubtitle with the book subtitle
  s = s.gsub("\\mybooksubtitle", "Nature-Inspired Programming Recipes")
  # finally switch ` for ' (late in the subs)
  s = s.gsub("`", "'")

  # put the math back
  if !math.empty?
    index = 0
    s = s.gsub(/\$([^$]+)\$/) do |m|
      index += 1
      "$#{math[index - 1]}$"
    end
  end
  if !arrays.empty?
    index = 0
    s = s.gsub(/\\\[([^$]+)\\\]/) do |m|
      index += 1
      "\\[#{arrays[index - 1]}\\]"
    end
  end
  return s
end

# create the pretty print
# http://code.google.com/p/google-code-prettify/
# http://google-code-prettify.googlecode.com/svn/trunk/README.html
def final_pretty_code_listing(lines, caption=nil, ruby_filename=nil)
  # remove trailining white space
  lines.each_with_index {|r,i| lines[i]=r.rstrip}
  # make a string
  raw = lines.join("\r\n") # windows friendly?
  # pretty print does not like <> brackets
  raw = process_angle_brackets_and_ampersands(raw)
  s = ""
  # table is a hack to ensure lines wrap
  add_line(s, "<pre class='prettyprint lang-rb'>")
  add_line(s, raw)
  add_line(s, "</pre>")
  if !caption.nil?
    caption = post_process_text(caption) # process text
    add_line(s, "<div class='caption'>#{caption}</div>")
  end
  if !ruby_filename.nil?
	  add_line(s, "<div class='download_src'>Download: <a href='#{ruby_filename}'>#{ruby_filename}</a>. Unit test available in the <%=natureinspired_dev_url(\"github project\")%></div>")
	end
  return s
end

def pretty_print_code_listing(code_listing_line)
  # get the file
  filename = get_data_in_brackets(code_listing_line)
  # get the caption
  parts = code_listing_line.split(",")
  raise "Caption not where expected" if !starts_with?(parts[2], "caption")
  caption = parts[2][(parts[2].index("=")+1)..-1]
  raw = IO.readlines(filename[(filename.index("/")+1)..-1])
  ruby_filename = filename[(filename.rindex("/")+1)..-1]
  # trim top 7 lines
  raw = raw[6..-1]
  s = final_pretty_code_listing(raw, caption, ruby_filename)
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
        e.gsub(/\\newpage\\begin\{bibunit\}\\input\{/) do |c|
          filename = e.match(/\\input\{([^}]+)\}/).to_s
          subpages << filename[(filename.rindex("/")+1)...-1]
          ""
        end
      else
        raise "got something unexpected in raw structure: #{e}"
      end
    end
  end while !stack.empty?
  return subpages
end

def process_authors(s)
  s = s.strip
  authors = []
  s = s.gsub("\n", " ")
  s = s.gsub("\r", " ")
  s.split(" and ").each do |author|
    author = author.strip
    if author.index(",").nil? or author.index(",")<0
      authors << author
    else
      parts = author.split(",")
      raise "error with author: #{author}" if parts.size > 2 or parts[0].nil? or parts[1].nil?
      authors << (parts[1].strip+" "+parts[0].strip)
    end
  end
  return authors.join(" and ")
end

# crunch text in bibtex fields to be human readable
def process_bibtex(datum)
  datum = datum.to_s
  # replace newlines with spaces
  datum = datum.gsub("\n", " ")
  # umlats etc
  datum = character_processing(datum)
  # replace things
  datum = datum.gsub(/\{([^}]+)\}/) {|c| c[1...-1] }
  datum = datum.gsub("~", " ")
  # replace \" and \' with nothing (any leftovers)
  datum = datum.gsub("\\\"", "")
  datum = datum.gsub("\\\'", "")
  # replace \- with nothing (hypenation suggestions)
  datum = datum.gsub("\\-", "")
  return datum
end

def to_google_scholar(title)
  title_link = title.gsub(" ", "+")
  title_link = title_link.gsub("\t", "+")
  title_link = title_link.gsub("\n", "+")
  link = "http://scholar.google.com.au/scholar?q=#{title_link}"
  return "<a href=\"#{link}\">#{title}</a>"
end


# considerig editor (where we already have an author) later in the listing
# assume ordering in http://en.wikipedia.org/wiki/BibTeX
def generate_bib_entry(entry)
  s = ""
  if entry.type == :book
    # author/editor, title, publisher, year
    if entry[:author].nil?
      # just eds
      raise "No author or editors" if entry[:editor].nil?
      s << "#{process_authors process_bibtex(entry[:editor])} (editors), "
    else
      s << "#{process_authors process_bibtex(entry[:author])}, "
    end
    s << "\"#{to_google_scholar process_bibtex(entry[:title])}\", "
    s << "#{process_bibtex entry[:publisher]}, " if !entry[:publisher].nil?
    s << "#{process_bibtex entry[:year]}."
  elsif entry.type == :article
    # author, title, journal, year
    s << "#{process_authors process_bibtex(entry[:author])}, "
    s << "\"#{to_google_scholar process_bibtex(entry[:title])}\", "
    s << "#{process_bibtex entry[:journal]}, " if !entry[:journal].nil?
    s << "#{process_bibtex entry[:year]}."
  elsif entry.type == :inbook
    # author/editor, title, chapter/pages, publisher, year
    if entry[:author].nil?
      # just eds
      raise "No author or editors" if entry[:editor].nil?
      s << "#{process_authors process_bibtex(entry[:editor])} (editors), "
    else
      s << "#{process_authors process_bibtex(entry[:author])}, "
    end
    s << "\"#{to_google_scholar process_bibtex(entry[:chapter])}\", " if !entry[:chapter].nil?
    s << "in #{process_bibtex entry[:title]}, "
    s << "pages #{process_bibtex entry[:pages]}, " if !entry[:pages].nil?
    s << "#{process_bibtex entry[:publisher]}, " if !entry[:publisher].nil?
    s << "#{process_bibtex entry[:year]}."
  elsif entry.type == :techreport
    # author, title, institution, year
    s << "#{process_authors process_bibtex(entry[:author])}, "
    s << "\"#{to_google_scholar process_bibtex(entry[:title])}\", "
    s << "Technical Report #{process_bibtex entry[:number]}, " if !entry[:number].nil?
    s << "#{process_bibtex entry[:institution]}, " if !entry[:institution].nil?
    s << "#{process_bibtex entry[:year]}."
  elsif entry.type == :inproceedings
    # author, title, booktitle, year
    if entry[:author].nil?
      # just eds
      raise "No author or editors" if entry[:editor].nil?
      s << "#{process_authors process_bibtex(entry[:editor])} (editors), "
    else
      s << "#{process_authors process_bibtex(entry[:author])}, "
    end
    s << "\"#{to_google_scholar process_bibtex(entry[:title])}\", "
    s << "in #{process_bibtex entry[:booktitle]}, " if !entry[:booktitle].nil?
    s << "#{process_bibtex entry[:year]}."
  elsif entry.type == :phdthesis
    # author, title, school, year
    s << "#{process_authors process_bibtex(entry[:author])}, "
    s << "\"#{to_google_scholar process_bibtex(entry[:title])}\", "
    s << "[PhD Thesis] "
    s << "#{process_bibtex entry[:school]}, " if !entry[:school].nil?
    s << "#{process_bibtex entry[:year]}."
  elsif entry.type == :mastersthesis
    # author, title, school, year
    s << "#{process_authors process_bibtex(entry[:author])}, "
    s << "\"#{to_google_scholar process_bibtex(entry[:title])}\", "
    s << "[Masters Thesis] "
    s << "#{process_bibtex entry[:school]}, " if !entry[:school].nil?
    s << "#{process_bibtex entry[:year]}."
  elsif entry.type == :incollection
    # author, title, booktitle, year
    s << "#{process_authors process_bibtex(entry[:author])}, "
    s << "\"#{to_google_scholar process_bibtex(entry[:title])}\", "
    s << "in #{process_bibtex entry[:booktitle]}, " if !entry[:booktitle].nil?
    s << "#{process_bibtex entry[:year]}."
  elsif entry.type == :conference
    # author, title, booktitle, year
    s << "#{process_authors process_bibtex(entry[:author])}, "
    s << "\"#{to_google_scholar process_bibtex(entry[:title])}\", "
    s << "in #{process_bibtex entry[:booktitle]}, " if !entry[:booktitle].nil?
    s << "#{process_bibtex entry[:year]}."
  elsif entry.type == :unpublished
    # author, title
    s << "#{process_authors process_bibtex(entry[:author])}, "
    s << "\"#{to_google_scholar process_bibtex(entry[:title])}\", "
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

def prepare_bibliography(data, bib)
  citations = collect_citations_for_page(data)
  hash = load_citations(citations, bib, data)
  s = ""
  add_line(s, "<table>")
  citations.each do |c|
    add_line(s, " <tr valign=\"top\">")
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
      add_line(s, "<caption align=\"bottom\">#{get_data_in_brackets(line)}</caption>")
    else
      lines = line.gsub("\\\\", "") # remove \\ on the end
      add_line(s, "<tr>")
      line.split("&").each do |td|
        td = post_process_text(td) # process text
        add_line(s, "<td>#{td.strip}</td>")
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
  caption = post_process_text(caption) # processing of text
  just_file = filename[(filename.index('/')+1)..-1]
  s = ""
  add_line(s, "<img src='/images/#{just_file}.png' align='middle' alt='#{caption}' class='book_image'>")
  add_line(s, "<br />")
  add_line(s, "<div class='caption'>#{caption}</div>")

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

def to_pseudocode_datum(map, item)
  p = item.strip
  key = p[1..-1] if p[0].chr == "\\"
  p = map[key] if !map[key].nil?
  p = "<code>#{p}</code>" if !p.include?("\$")
  return p
end

def pseudocode_term(term)
  return term if term.include?("\$")
  return "<code>#{term}</code>"
end

def pseudocode_keyword(term)
  return term if term.include?("\$")
  return "<strong><code>#{term}</code></strong>"
end

def replace_data(map, line)
  # data based (ending in a space or comma or a semi)
  map.keys.each do |key|
    line = line.gsub("\\#{key} ", "#{pseudocode_term map[key]} ") # space
    line = line.gsub("\\#{key},", "#{pseudocode_term map[key]},") # comma
    line = line.gsub("\\#{key}}", "#{pseudocode_term map[key]}}") # }
    line = line.gsub("\\#{key})", "#{pseudocode_term map[key]})") # )
    line = line.gsub("\\#{key}\\;", "#{pseudocode_term map[key]}\\;") # semicolon
  end
  return line
end

def replace_functions(map, line)
  # same with func map, end in {
  map.keys.each do |key|
    line = line.gsub("\\#{key}{", "#{pseudocode_term map[key]}{") # bracket
    line = line.gsub("\\#{key}(", "#{pseudocode_term map[key]}(") # bracket
  end
  # easy no param functions
  line = line.gsub("{}", "()")
  return line
end

def basic_math_replace(current, replacement)
	#puts "[#{current}], [#{replacement}]"
	# don't do math where we don't have to
	return "&gt;" if current.strip == "$>$"
	return "&lt;" if current.strip == "$<$"
	return "&ndash;" if current.strip == "$-$"
	return "+" if current.strip == "$+$"
	return "$#{replacement}$"
end

PSEUDOCODE_KEYWORDS = {"While"=>"While", "If"=>"If", "eIf"=>"If",
  "Return"=>"Return", "ForEach"=>"ForEach", "For"=>"For"}

def process_pseudocode(lines, caption=nil)
  datamap, funcmap = {}, {}
  s = ""
  add_line(s, "<div class='pseudocode'>")
  lines.each do |line|
    line = line.rstrip
    # skip
    next if starts_with?(line.strip, "\\label")
    next if starts_with?(line.strip, "\\caption")
    next if starts_with?(line.strip, "\\SetLine")
    # build map
    if starts_with?(line.strip, "\\SetKwData") or starts_with?(line.strip, "\\SetKwFunction")
      p1 = line[(line.index("{")+1)...line.index("}")]
      sub = line[(line.index("}")+1)..-1]
      i,j = (sub.index("{")+1), sub.rindex("}")
      p2 = sub[i...j]
      map = starts_with?(line.strip, "\\SetKwData") ? datamap : funcmap
      map[p1] = p2
    # IO
    elsif starts_with?(line.strip, "\\KwIn") or starts_with?(line.strip, "\\KwOut")
      content = get_data_in_brackets(line)
      parts = []
      content.split(",").each do |part|
        parts << to_pseudocode_datum(datamap, part)
      end
      next if parts.empty?
      type = (starts_with?(line.strip, "\\KwIn")) ? "Input" : "Output"
      add_line(s, "<strong>#{pseudocode_keyword type}</strong>: ")
      add_line(s, parts.join(", "))
      add_line(s, "<br />")
    else
      # attempting a low-tech solution here - just to get over the line

      # repeat...until on one line
      if starts_with?(line.strip, "\\Repeat")
      	depth = line[0...line.index("\\Repeat")]
        p1 = line[(line.index("{")+1)...line.index("}")]
        sub = line[(line.index("}")+1)..-1]
        i, j = (sub.index("{")+1), sub.rindex("}")
        p2 = sub[i...j]
        line = ""
        # only used in DE!
        add_line(line, "\t#{pseudocode_keyword("Repeat")}<br />")
        add_line(line, "\t#{pseudocode_keyword(p2)}\\;<br />")
        add_line(line, "#{pseudocode_keyword("Until")} #{pseudocode_keyword(p1)}\\;")
      end
      # for
      if starts_with?(line.strip, "\\For")
        content = get_data_in_brackets(line)
        line = line[0...(line.index("\\For"))] + "#{pseudocode_keyword("For")} (#{content})"
      end
      if starts_with?(line.strip, "\\While")
        content = get_data_in_brackets(line)
        line = line[0...(line.index("\\While"))] + "#{pseudocode_keyword("While")} (#{content})"
      end
      if starts_with?(line.strip, "\\If")
        content = get_data_in_brackets(line)
        line = line[0...(line.index("\\If"))] + "#{pseudocode_keyword("If")} (#{content})"
      end
      if starts_with?(line.strip, "\\eIf")
        content = get_data_in_brackets(line)
        line = line[0...(line.index("\\eIf"))] + "#{pseudocode_keyword("If")} (#{content})"
      end
      if starts_with?(line.strip, "\\uIf")
        content = get_data_in_brackets(line)
        line = line[0...(line.index("\\uIf"))] + "#{pseudocode_keyword("If")} (#{content})"
      end
      if starts_with?(line.strip, "}\\uElseIf{")
        content = get_data_in_brackets(line)
        line = line[0...(line.index("}\\uElseIf{"))] + "#{pseudocode_keyword("ElseIf")} (#{content})"
      end
      if starts_with?(line.strip, "}\\ElseIf")
        content = get_data_in_brackets(line)
        line = line[0...(line.index("}\\ElseIf"))] + "#{pseudocode_keyword("ElseIf")} (#{content})"
      end
      if starts_with?(line.strip, "\\Return")
        content = get_data_in_brackets(line)
        line = line[0...(line.index("\\Return"))] + "#{pseudocode_keyword("Return")} (#{content})"
      end
      # take out the math
      math = []
      line.scan(/\$([^$]+)\$/) {|m| math << m.to_s } # $$
      # brackets
      line = line.gsub("{", "(")
			line = line.gsub("}", ")")
      # put the math back
      if !math.empty?
        # process the math
        math.each_index do |i|
          math[i] = replace_data(datamap, math[i])
          math[i] = replace_functions(funcmap, math[i])
          # remove all sub-math
          math[i] = math[i].gsub("$", "")
          # remove html
          math[i] = math[i].gsub("<code>", "")
          math[i] = math[i].gsub("</code>", "")
        end
        # put the math back
        index = 0
        line = line.gsub(/\$([^$]+)\$/) do |m|
          index += 1
          #"$#{math[index - 1]}$"
          basic_math_replace(m, math[index-1])
        end
      end
      # replace data
      line = replace_data(datamap, line)
      # replace functions
      line = replace_functions(funcmap, line)
      # strings
			line = line.gsub("``", "&quot;")
			line = line.gsub("''", "&quot;")
      # keywords
      PSEUDOCODE_KEYWORDS.keys.each do |key|
        line = line.gsub("\\#{key}{", "#{pseudocode_keyword PSEUDOCODE_KEYWORDS[key]}{") # bracket
      end
      # special keywords
      line = line.gsub("$\\KwTo$", "#{pseudocode_keyword("To")}")
      line = line.gsub("\\KwTo", "#{pseudocode_keyword("To")}")
      line = line.gsub("\\Break", "#{pseudocode_keyword("Break")}")
      line = line.gsub("TRUE", "#{pseudocode_keyword("True")}")
      line = line.gsub("FALSE", "#{pseudocode_keyword("False")}")
      if line.strip == "}{" or line.strip == ")("
        line = line.gsub("}{", "#{pseudocode_keyword("Else")}")
        line = line.gsub(")(", "#{pseudocode_keyword("Else")}") # HACK
      elsif line.strip == "}" or line.strip == ")" # hack
      	line = line.gsub("}", "#{pseudocode_keyword("End")}")
      	line = line.gsub(")", "#{pseudocode_keyword("End")}") # HACK
      end
      # remove the first tab
      line = line[1..-1] if line[0].chr == "\t"
      # replace tabs
      line = line.gsub("\t", "&nbsp;&nbsp;&nbsp;&nbsp;")
      # now replace new lines
      line = line.gsub("\\;", "")
      add_line(s, "#{line}<br />")
    end
  end
  add_line(s, "</div>")
  add_line(s, "<div class='caption'>#{post_process_text(caption)}</div>") if !caption.nil?
  return s
end

def to_text_content(data)
  s = ""
  # state machine for building paragraphs/items/algorithms
  out, in_items, in_algorithm, in_listing, in_enum = true, false, false, false, false
  in_table, in_align, in_equation, in_figure = false, false, false, false
  in_desc = false
  algorithm_caption = nil
  table_collection, align_collection, equation_collection, figure_collection = [], [], [], []
  listing_collection, pseudocode_collection = [], []
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
      add_line(s, process_pseudocode(pseudocode_collection, algorithm_caption))
      algorithm_caption, pseudocode_collection = nil, []
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
    elsif starts_with?(line, "\\begin{description}") # start description
      s << "</p>\n" if !out # end paragraph
      add_line(s, "<ol>")
      out, in_desc = true, true
    elsif starts_with?(line, "\\end{description}")  # end description
      out, in_desc = true, false
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
        elsif in_desc
          l1 = post_process_text(line).gsub("\\item", "") # remove \item
          l2 = l1.match(/\[([^}]+)\]/).to_s # bold bracketed part
          add_line(s, "<li><strong>#{l2[1...-1]}</strong>#{l1[l2.size..-1]}</li>")
        elsif in_algorithm
          # ignore (for now)
          algorithm_caption = get_data_in_brackets(line) if starts_with?(line, "\\caption{")
          pseudocode_collection << raw_line # unstripped
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
          add_line(s, "<p>")
          add_line(s, post_process_text(line)) # HERE formatting to lines
          out = false
        end
      else
        add_line(s, post_process_text(line)) # HERE formatting to lines
      end
    end
  end
  add_line(s, "</p>") if !out
  return s
end

def get_algorithm_name(filename)
  lines = get_all_data_lines(filename)
  processed = general_process_file(lines)
  return processed.last[:section]
end

def to_anchor(name)
  name = post_process_text(name)
  name = name.downcase
  name = name.gsub(" ", "_")
  name = name.gsub("\n", "_")
  return name
end

# for intro chapter (at least)
# note headings are processed
def header_for_hash(hash, has_chapter)
  if !has_chapter
    return "<h1><a name='#{to_anchor(hash[:section])}'>#{post_process_text hash[:section]}</a></h1>" if !hash[:section].nil?
    return "<h2><a name='#{to_anchor(hash[:subsec])}'>#{post_process_text hash[:subsec]}</a></h2>" if !hash[:subsec].nil?
    return "<h3><a name='#{to_anchor(hash[:subsubsec])}'>#{post_process_text hash[:subsubsec]}</a></h3>" if !hash[:subsubsec].nil?
  end
  return "<h1><a name='#{to_anchor(hash[:chapter])}'>#{post_process_text hash[:chapter]}</a></h1>" if !hash[:chapter].nil?
  return "<h2><a name='#{to_anchor(hash[:section])}'>#{post_process_text hash[:section]}</a></h2>" if !hash[:section].nil?
  return "<h3><a name='#{to_anchor(hash[:subsec])}'>#{post_process_text hash[:subsec]}</a></h3>" if !hash[:subsec].nil?
  return "<h4><a name='#{to_anchor(hash[:subsubsec])}'>#{post_process_text hash[:subsubsec]}</a></h4>" if !hash[:subsubsec].nil?
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

def head(name, parent, keywords)
  s = ""
  # title
  if parent.nil?
    add_line(s, "<% content_for :head_title, \"#{name} - Clever Algorithms: Nature-Inspired Programming Recipes\" %>")
  else
    add_line(s, "<% content_for :head_title, \"#{name} - Clever Algorithms: Nature-Inspired Programming Recipes\" %>")
  end
  # description
  if parent.nil?
    add_line(s, "<% content_for :head_description, \"#{name} - Clever Algorithms: Nature-Inspired Programming Recipes\" %>")
  else
    add_line(s, "<% content_for :head_description, \"#{name} - #{parent} - Clever Algorithms: Nature-Inspired Programming Recipes\" %>")
  end
  # keywords
  if keywords.nil? or keywords.empty?
    if parent.nil?
      add_line(s, "<% content_for :head_keywords, \"#{name}, Clever Algorithms\" %>")
    else
       add_line(s, "<% content_for :head_keywords, \"#{name}, #{parent}, Clever Algorithms\" %>")
    end
  else
    add_line(s, "<% content_for :head_keywords, \"#{keywords}, Clever Algorithms\" %>")
  end
  return s
end

def breadcrumb(current, name, parent=nil)
  s = ""
  add_line(s, "<div class='breadcrumb'>")
  if parent.nil?
    add_line(s, "<a href='index.html'>Table of Contents</a>")
    add_line(s, "&gt;&gt;")
  else
    add_line(s, "<a href='../index.html'>Table of Contents</a>")
    add_line(s, "&gt;&gt;")
    add_line(s, "<a href='../#{parent[:link]}.html'>#{parent[:name]}</a>")
    add_line(s, "&gt;&gt;")
  end
  add_line(s, "<a href='#{current}.html'>#{name}</a>")
  add_line(s, "</div>")
  return s
end

def get_keywords(data)
  keywords = nil
  data.last[:content].each do |line|
    next if line.nil? or line.empty?
    next if !line.kind_of?(String)
    line = line.strip
    if starts_with?(line, "\\emph{")
      keywords = line
      break
    end
  end
  return "" if keywords.nil?
  keywords = get_data_in_brackets(keywords)
  keywords = keywords[0...(keywords.size-1)] if keywords[keywords.size-1].chr == "."
  return keywords
end

def html_for_algorithm(name, data, bib, parent)
  s = ""
  s << head(data.last[:section], parent[:name], get_keywords(data))
  s << breadcrumb(name, data.last[:section], parent)
  s << recursive_html_for_chapter(data, false)
  # bib
  add_line(s, "<h2>Bibliography</h2>")
  add_line(s, prepare_bibliography(data, bib))
  return s
end

def html_for_chapter_overview(name, data, source, bib, subsecname)
  algos = collect_subpages_for_page(data)
  keywords = []
  algos.each{|a| keywords << get_algorithm_name(source+"/"+a+".tex")}
  s = ""
  s << head(data.last[:chapter], nil, keywords.join(", "))
  s << breadcrumb(name, data.last[:chapter])
  s << recursive_html_for_chapter(data)
  # Overview (such as an algorithms list)
  overview = ""
  add_line(overview, "<h3>#{subsecname}</h3>")
  add_line(overview, "<ul>")
  algos.each do |filename|
    # super lazy at getting algorithm names - consider a better process
    algo_name = get_algorithm_name(source+"/"+filename+".tex")
    add_line(overview, "<li><a href='#{name}/#{filename}.html'>#{algo_name}</a></li>")
  end
  add_line(overview, "</ul>")
  # work out the best place for the overview
  # check for algorithms chapter that has an "Extensions" section
  target = "Extensions</a></h3>"
  if (s.include?(target))
    index = s.rindex(target)
    tmp = s[0...index]
    pos = tmp.rindex("<h3>")
    # super safe
    if !pos.nil?
      s.insert(pos, overview)
    else
      s << overview
    end
  else
   s << overview
  end
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
  lines = get_all_data_lines("book/c_#{name}.tex")
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
  source = "book/a_"+name
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
    html = html_for_algorithm(file[0...-4], processed, bib, parent)
    filename = "#{dirname}/#{file[0...-4]}.html"
    File.open(filename, 'w') {|f| f.write(html) }
    puts " > successfully wrote algorithm '#{processed.first[:section]}' to: #{filename}"
  end
end

def html_for_chapter(name, data, bib)
  s = ""
  s << head(post_process_text(data.last[:chapter]), nil, nil)
  s << breadcrumb(name, post_process_text(data.last[:chapter]))
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
  lines = get_all_data_lines("book/#{name}.tex")
  processed = general_process_file(lines)
  output = name[(name.index('_')+1)..-1]
  html = html_for_chapter(output, processed, bib)
  filename = OUTPUT_DIR + "/"+output+".html"
  File.open(filename, 'w') {|f| f.write(html) }
  puts " > successfully wrote chapter '#{name}' to: #{filename}"
end

def build_advanced_chapter(bib, name="advanced")
  dirname = OUTPUT_DIR + "/"+name
  create_directory(dirname)
  source = "book/c_"+name
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
    html = html_for_algorithm(file[0...-4], processed, bib, parent)
    filename = "#{dirname}/#{file[0...-4]}.html"
    File.open(filename, 'w') {|f| f.write(html) }
    puts " > successfully wrote topic '#{processed.first[:section]}' to: #{filename}"
  end
end

def build_appendix(bib, name="appendix1")
  lines = get_all_data_lines("book/b_#{name}.tex")
  processed = general_process_file(lines)
  html = html_for_chapter(name, processed, bib)
  filename = OUTPUT_DIR + "/"+name+".html"
  File.open(filename, 'w') {|f| f.write(html) }
  puts " > successfully wrote appendix '#{name}' to: #{filename}"
end

def build_errata(bib, name="errata")
  lines = get_all_data_lines("book/b_#{name}.tex")
  processed = general_process_file(lines)
  html = html_for_chapter(name, processed, bib)
  filename = OUTPUT_DIR + "/"+name+".html"
  File.open(filename, 'w') {|f| f.write(html) }
  puts " > successfully wrote errata '#{name}' to: #{filename}"
end

def create_toc_html(algorithms, frontmatter)
  s = ""
  # head
  add_line(s, "<% content_for :head_title, \"Clever Algorithms: Nature-Inspired Programming Recipes\" %>")
  add_line(s, "<% content_for :head_description, \"Clever Algorithms: Nature-Inspired Programming Recipes\" %>")
  add_line(s, "<% content_for :head_keywords, \"clever algorithms, computational intelligence, artificial intelligence, metaheuristics, biologically inspired natural, table of contents\" %>")
  # front matter
  add_line(s, "<h1>Table of Contents</h1>")
  add_line(s, "<ol>")
  add_line(s, "<li><a href='copyright.html'>copyright</a></li>") # hard code copyright
  frontmatter.each do |name|
    output = name[(name.index('_')+1)..-1]
    add_line(s, "<li><a href='#{output}.html'>#{output}</a></li>")
  end
  # intro
  add_line(s, "<li><strong>Background</strong></li>")
  add_line(s, "<ol>")
  add_line(s, "<li><a href='introduction.html'>Introduction</a></li>")
  add_line(s, "<ol>")
  # add intro subsections
  lines = get_all_data_lines("book/c_introduction.tex")
  intro = general_process_file(lines)
  intro.last[:content].each do |element|
    next if !element.kind_of?(Hash)
    add_line(s, "<li><a href='introduction.html\##{to_anchor(element[:section])}'>#{element[:section]}</a></li>")
  end
  add_line(s, "</ol>")
  add_line(s, "</ol>")
  # algorithms
  add_line(s, "<li><strong>Algorithms</strong></li>")
  add_line(s, "<ol>")
  algorithms.each do |name|
    lines = get_all_data_lines("book/c_#{name}.tex")
    data = general_process_file(lines)
    add_line(s, "<li><a href='#{name}.html'>#{data.last[:chapter]}</a></li>")
    algos = collect_subpages_for_page(data)
    add_line(s, "<ol>")
    algos.each do |filename|
      # super lazy at getting algorithm names - consider a better process
      algo_name = get_algorithm_name("book/a_#{name}/"+filename+".tex")
      add_line(s, "<li><a href='#{name}/#{filename}.html'>#{algo_name}</a></li>")
    end
    add_line(s, "</ol>")
  end
  add_line(s, "</ol>")
  # advanced
  add_line(s, "<li><strong>Extensions</strong></li>")
  begin
    add_line(s, "<ol>")
    lines = get_all_data_lines("book/c_advanced.tex")
    data = general_process_file(lines)
    add_line(s, "<li><a href='advanced.html'>#{data.last[:chapter]}</a></li>")
    algos = collect_subpages_for_page(data)
    add_line(s, "<ol>")
    algos.each do |filename|
      # super lazy at getting algorithm names - consider a better process
      algo_name = get_algorithm_name("book/c_advanced/"+filename+".tex")
      add_line(s, "<li><a href='advanced/#{filename}.html'>#{algo_name}</a></li>")
    end
    add_line(s, "</ol>")
    add_line(s, "</ol>")
  end
  # appendix
  add_line(s, "<li><a href='appendix1.html'>Appendix A - Ruby: Quick-Start Guide</a></li>")
  add_line(s, "<ol>")
  # add appendix subsections
  lines = get_all_data_lines("book/b_appendix1.tex")
  appendix = general_process_file(lines)
  appendix.last[:content].each do |element|
    next if !element.kind_of?(Hash)
    add_line(s, "<li><a href='appendix1.html\##{to_anchor(element[:section])}'>#{element[:section]}</a></li>")
  end
  add_line(s, "</ol>")
  # errata
  add_line(s, "<li><a href='errata.html'>Errata</a></li>")
  add_line(s, "</ol>")
  return s
end

def build_toc(algorithms, frontmatter)
  html = create_toc_html(algorithms, frontmatter)
  filename = OUTPUT_DIR + "/index.html"
  File.open(filename, 'w') {|f| f.write(html) }
  puts " > successfully wrote toc to: #{filename}"
end

def html_for_copyright(output, lines)
  s = ""
  s << head("Copyright", nil, nil)
  s << breadcrumb("copyright", "Copyright")
  add_line(s, "<h1>Copyright</h1>")
  # process section
  lines.each do |line|
    if starts_with?(line, "\\subsubsection")
      add_line(s, "<h2>#{post_process_text(get_data_in_brackets(line))}</h2>")
    else
      add_line(s, post_process_text(line))
    end
  end
  return s
end

# lazy
def build_copyright(name="f_copyright")
  lines = get_all_data_lines("book/#{name}.tex")
  output = name[(name.index('_')+1)..-1]
  html = html_for_copyright(output, lines)
  filename = OUTPUT_DIR + "/"+output+".html"
  File.open(filename, 'w') {|f| f.write(html) }
  puts " > successfully wrote copyright '#{name}' to: #{filename}"
end

def get_ruby_into_position(chapters)
	# all algorithm chapters
	chapters.each do |chapter|
		source = "book/a_"+chapter
		Dir.entries(source).each do |file|
		  next if file == "." or file == ".."
		  next if File.extname(file) != ".tex"
		  # load and process the algorithm
		  lines = get_all_data_lines(source + "/" + file)
		  # locate link to file
		  filename = nil
		  lines.each do |line|
		  	if starts_with?(line.strip, "\\lstinputlisting[firstline=")
		  		filename = get_data_in_brackets(line)
		  		break
		  	end
		  end
		  raise "could not locate ruby file in #{source + "/" + file}" if filename.nil?
		  # load
			raw = IO.readlines(filename[(filename.index("/")+1)..-1])
			ruby_filename = OUTPUT_DIR + "/" + chapter + "/" + filename[(filename.rindex("/")+1)..-1]
			# write
			File.open(ruby_filename, 'w') {|f| f.write(raw.join("")) }
		end
	end
	# process advanced chapter
	begin
		chapter = "advanced"
		source = "book/c_"+chapter
		Dir.entries(source).each do |file|
		  next if file == "." or file == ".."
		  next if File.extname(file) != ".tex"
		  # load and process the algorithm
		  lines = get_all_data_lines(source + "/" + file)
		  # locate link to file
		  filenames = []
		  lines.each do |line|
		  	if starts_with?(line.strip, "\\lstinputlisting[")
		  		filenames << get_data_in_brackets(line)
		  	end
		  end
		  next if filenames.empty? # some have no files
		  # load
		  filenames.each do |filename|
				raw = IO.readlines(filename[(filename.index("/")+1)..-1])
				ruby_filename = OUTPUT_DIR + "/" + chapter + "/" + filename[(filename.rindex("/")+1)..-1]
				# write
				File.open(ruby_filename, 'w') {|f| f.write(raw.join("")) }
		  end
		end
	end
end

def add_image(s, host, filename)
	add_line(s, "\t\t<image:image>")
	add_line(s, "\t\t\t<image:loc>#{host}/images/#{filename}</image:loc>")
	add_line(s, "\t\t</image:image>")
end

def add_url_to_sitemap(s, host, dir, path)
	add_line(s, "\t<url>")
	url = host
	url = url+"/"+dir if !dir.nil?
	url = url+"/"+path if !path.nil?
	add_line(s, "\t\t<loc>#{url}</loc>")
	add_line(s, "\t</url>")
end

def add_code_url_to_sitemap(s, host, dir, path)
	add_line(s, "\t<url>")
	url = host
	url = url+"/"+dir if !dir.nil?
	url = url+"/"+path if !path.nil?
	add_line(s, "\t\t<loc>#{url}</loc>")
	# special code stuff
	add_line(s, "\t\t<codesearch:codesearch>")
	add_line(s, "\t\t\t<codesearch:filetype>ruby</codesearch:filetype>")
	add_line(s, "\t\t</codesearch:codesearch>")
	add_line(s, "\t</url>")
end

def create_sitemap
	s = ""
	add_line(s, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
	add_line(s, "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\" xmlns:image=\"http://www.google.com/schemas/sitemap-image/1.1\" xmlns:codesearch=\"http://www.google.com/codesearch/schemas/sitemap/1.0\">")
	# html
	host = "http://www.cleveralgorithms.com"
	dir = "nature-inspired"
	# all pages
	Dir.entries(OUTPUT_DIR).each do |file|
		next if file == "." or file == ".."
		if File.directory?(OUTPUT_DIR+"/"+file)
			Dir.entries(OUTPUT_DIR+"/"+file).each do |subfile|
				next if subfile == "." or subfile == ".."
				if File.extname(subfile) == ".rb"
          # add_code_url_to_sitemap(s, host, dir, "#{file}/#{subfile}")
          next
				elsif File.extname(subfile) == ".html"
					add_url_to_sitemap(s, host, dir, "#{file}/#{subfile}")
				end
			end
		else
			next if File.extname(file) != ".html"
			add_url_to_sitemap(s, host, dir, file)
		end
	end
	add_line(s, "</urlset>")
	filename = OUTPUT_DIR+"/sitemap.xml"
	File.open(filename, 'w') {|f| f.write(s) }
	puts " > successfully wrote sitemap : #{filename}"
end

# these are ordered
ALGORITHM_CHAPTERS = ["stochastic", "evolution", "physical", "probabilistic", "swarm", "immune", "neural"]
FRONT_MATTER = ["f_foreword", "f_preface", "f_acknowledgments"]

if __FILE__ == $0
  # create dir
  create_directory(OUTPUT_DIR)
  # load the bib
  bib = load_bibtex()
  # TOC
  build_toc(ALGORITHM_CHAPTERS, FRONT_MATTER)
  # front matter
  build_copyright()
  FRONT_MATTER.each {|name| build_chapter(bib, name) }
  # introduction chapter
  build_chapter(bib, "c_introduction")
  # process algorithm chapters
  ALGORITHM_CHAPTERS.each {|name| build_algorithm_chapter(name, bib) }
  # advaced topics
  build_advanced_chapter(bib)
  # appendix
  build_appendix(bib)
  # eratta
  build_errata(bib)
  # ruby files
  get_ruby_into_position(ALGORITHM_CHAPTERS)
  # site map
  create_sitemap
end
