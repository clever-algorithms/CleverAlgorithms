require 'rubygems'
require 'generate'
require 'pp'
require 'cgi'
require 'digest/sha1'

begin 
  require 'eeepub'
rescue LoadError
  puts "Sorry! You need to 'gem install eeepub' first!"
  exit
end

begin 
  require 'httpclient'
rescue LoadError
  puts "Sorry! You need to 'gem install httpclient' first!"
  exit
end

OUTPUT_DIR = "epub_temp"

def render_latex_as_image(latex, filename)
  url = "http://mathcache.appspot.com/?tex=#{CGI.escape('\\png \\small \\parstyle '+latex)}"
  client = HTTPClient.new
  binary_data = client.get_content(url)
  File.open("#{OUTPUT_DIR}/#{filename}", 'w') do |file| 
    file << binary_data  
  end
end

def replace_latex_with_image_tags(html)
  math = []
  html.scan(/\$(.+?)\$/) {|m| math << m } # $$
  index = 0
  html.gsub!(/\$(.+?)\$/) do |m|
    index += 1
    filename = "LaTeX#{Digest::SHA1.hexdigest(m)}.png"
    render_latex_as_image(m, filename) unless File.exists?("#{OUTPUT_DIR}/#{filename}")
    "<img class='math' src='#{filename}'/>"
  end
end

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
    #{text}
  </body>
</html>  
END
  File.open(filename, 'w') << text
end


def build_navigation_map
  result = []
  result += FRONT_MATTER.map do |topic|
    stripped = topic[2..-1]
    {:label => stripped.capitalize,
     :content => "#{stripped}.html"}
  end
  result += ALGORITHM_CHAPTERS.map do |topic|
    item = {:label => "#{topic.capitalize} Algorithms",
     :content => "#{topic}.html"}     
    lines = get_all_data_lines("../book/c_#{topic}.tex")
    data = general_process_file(lines)
    algos = collect_subpages_for_page(data)
    item[:nav] = algos.map do |algo|
      {:label => get_algorithm_name("../book/a_#{topic}/"+algo+".tex"),
       :content => "#{algo}.html"}
    end
    item
  end  
  result
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

    files Dir.glob("./epub/**")+ordered_html_files+Dir.glob("./#{OUTPUT_DIR}/LaTeX*.png")
    nav navigation_map
  end
  puts "Building epub file"
  epub.save('CleverAlgorithms.epub')
end

