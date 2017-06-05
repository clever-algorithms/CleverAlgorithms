# Script for converting the web-site to an epub-book
# builds upon and extends the 'big collection of hacks' that is generate.rb in the same rogue spirit.

# Contributed by Simen Svale Skogsrud january 2011
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

# updated to use google chart for generating equations, still not working well...

require 'rubygems'
require File.expand_path(File.dirname(__FILE__)) + '/generate'
require 'pp'
require 'cgi'
require 'digest/sha1'
require 'eeepub'
require 'httpclient'

OUTPUT_DIR = "build/epub_temp"

# Returns the svg for the latex expression
def render_svg(latex)
  client = HTTPClient.new
  wrapped_svg=client.get_content("https://chart.googleapis.com/chart?cht=tx&chl=#{CGI.escape(latex)}")
  wrapped_svg =~ (/".+":\s"(.*)\"\}\)/)
  return $1.gsub('\"','"')
end

# Renders the provided latex markup into a file with the given name
def render_latex_as_image(latex, filename)
  url = "https://chart.googleapis.com/chart?cht=tx&chof=png&chl=#{CGI.escape(latex)}"
  client = HTTPClient.new
  binary_data = client.get_content(url)
  File.open("#{OUTPUT_DIR}/#{filename}", 'w') do |file|
    file << binary_data
  end
  # File.open("#{OUTPUT_DIR}/#{filename.gsub('.png', '.svg')}", 'w') do |file|
  #   file << render_svg(latex)
  # end
end

# Replaces all latex in the html with img-tags to rendered images
def replace_latex_with_image_tags(html)
  html.gsub!(/\$(.+?)\$/) do |m|
    filename = "LaTeX#{Digest::SHA1.hexdigest(m)}.png"
    render_latex_as_image(m, filename) unless File.exists?("#{OUTPUT_DIR}/#{filename}")
    "<img class='math' src='#{filename}'/>"
  end
end

# Convert a file headed for the web into an epub-compliant thing
def epubize_file(filename)
  puts "Epubizing #{filename}"
  text = File.read(filename)
  # Strip template code
  text.gsub!(/\<\%[^%]*\%\>\s*/, '')
  # Strip breadcrumbs
  text.gsub!(/\<div class\=\'breadcrumb\'\>.*?\<\/div\>/m,'')
  # Change name attributes to id attributes, cause epub wants it that way
  text.gsub!(/\<a\s+name\=/, "<a id=")
  # Remove path from internal links
  text.gsub!(/href='\w+\//, "href='")
  # Remove download links
  text.gsub!(/<div class='download_src'>.*?Download Source<\/a><\/div>/, '')
  replace_latex_with_image_tags(text)
  # Wrap in suitable XHTML skeleton
  text = <<-END
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
  <head>
    <meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8" />
    <title>Clever Algorithms</title>
    <link rel="stylesheet" href="main.css" type="text/css" />
  </head>
  <body>
    <div id='chapter'>
      #{text}
    </div>
  </body>
</html>
END
  File.open(filename, 'w') << text
end

# Buld the list of sub-pages to a topic for an epub 'nav' array
def nav_for_topic(topic, label, folder_prefix_letter)
  item = {:label => label,
   :content => "#{topic}.html"}
  lines = get_all_data_lines("book/c_#{topic}.tex")
  data = general_process_file(lines)
  subpages = collect_subpages_for_page(data)
  item[:nav] = subpages.map do |page|
    {:label => get_algorithm_name("book/#{folder_prefix_letter}_#{topic}/#{page}.tex"),
     :content => "#{page}.html"}
  end
  item
end

# Build the table of contents
def build_navigation_map
  # AFAIK there is no way to extract the structure and titles of the different
  # sections of the book automatically, so this method is not entirely dependent
  # on generate.rb or the LaTeX-files. When the books structure changes beyond
  # adding algorithms or algorithm-chapters, this method must be updated.
  result = []
  # Front matter
  result += (['f_copyright']+FRONT_MATTER).map do |topic|
    stripped = topic[2..-1]
    {:label => stripped.capitalize,
     :content => "#{stripped}.html"}
  end
  # The Introduction
  result << {
    :label => "Introduction",
    :content => 'introduction.html'
  }
  # Algorithms
  result += (ALGORITHM_CHAPTERS).map do |topic|
    nav_for_topic(topic, "#{topic.capitalize} Algorithms", 'a')
  end
  # Extensions
  result += [nav_for_topic('advanced', 'Advanced Topics', 'c')]
  # Appendix
  result << {:label => "Appendix A - Ruby: Quick Start Guide",
    :content => 'appendix1.html'}
  result
end

# Replace LaTeX-png links with svg-links
def replace_png_links_with_svg_links_in_all_html_files
  Dir.glob("./#{OUTPUT_DIR}/**/*.html").each do |filename|
    text = File.read(filename)
    text.gsub!(/src='LaTeX([0-9a-f]+).png'/) do |digest|
      "src='LaTeX#{$1}.svg'"
    end
    File.open(filename, 'w') do |f|
      f << text
    end
  end
end

# Inline the svg (not used, it seems support is very immature)
def replace_png_links_with_inline_svg
  Dir.glob("./#{OUTPUT_DIR}/**/*.html").each do |filename|
    text = File.read(filename)
    text.gsub!(/<img class='math' src='LaTeX([0-9a-f]+)\.png'\/>/) do |digest|
      svg = File.read("./#{OUTPUT_DIR}/LaTeX#{$1}.svg")
      svg.gsub!(/\<\?xml.*?dtd'\>/, '')
      svg
    end
    File.open(filename, 'w') do |f|
      f << text
    end
  end
end

if __FILE__ == $0
  # create dir
  create_directory(OUTPUT_DIR)
  # load the bib
  bib = load_bibtex()
  # TOC
  # build_toc(ALGORITHM_CHAPTERS, FRONT_MATTER)
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

  puts "Epubizing html-files"
  Dir.glob("./#{OUTPUT_DIR}/**/*.html").each do |file|
    epubize_file(file)
  end

  # ruby files
  get_ruby_into_position(ALGORITHM_CHAPTERS)

  puts "Build navigation map"
  navigation_map = build_navigation_map
  pp navigation_map

  # Extract the order of the html-files from the nav-map
  ordered_html_files = navigation_map.map{|item| pp item; [item]+(item[:nav] || []) }.flatten.map{|i| i[:content] }
  # And remap them to the file hierarchy
  ordered_html_files = ordered_html_files.map{|file| Dir.glob("./#{OUTPUT_DIR}/**/#{file}").first }

  epub = EeePub.make do
    title       'Clever Algorithms'
    creator     'Jason Brownlee'
    publisher   'cleveralgoritms.com'
    date        Time.now.strftime("%Y-%m-%d")
    identifier  'urn:uuid:978-1-4467-8506-5-x', :scheme => 'ISBN'
    uid         'http://www.cleveralgorithms.com/'

    files Dir.glob("./web/epub_assets/**")+ordered_html_files+Dir.glob("./#{OUTPUT_DIR}/LaTeX*.png")
    nav navigation_map
  end
  puts "Building epub file with LaTeX in pngs"
  epub.save('build/CleverAlgorithms_png.epub')

  # replace_png_links_with_svg_links_in_all_html_files

  # epub = EeePub.make do
  #   title       'Clever Algorithms'
  #   creator     'Jason Brownlee'
  #   publisher   'cleveralgoritms.com'
  #   date        Time.now.strftime("%Y-%m-%d")
  #   identifier  'urn:uuid:978-1-4467-8506-5-x', :scheme => 'ISBN'
  #   uid         'http://www.cleveralgorithms.com/'

  #   files Dir.glob("./web/epub_assets/**")+ordered_html_files+Dir.glob("./#{OUTPUT_DIR}/LaTeX*.svg")
  #   nav navigation_map
  # end
  # puts "Building epub file with LaTeX in svgs"
  # epub.save('build/CleverAlgorithms_svg.epub')
end

