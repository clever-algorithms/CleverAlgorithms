# selection.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. All Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

# Description:
# Enumerate a listing of algorithms (algorithms.txt) and locate the approximate number of results
# from a number of different search engines and search domains (google). Rank the listing of 
# algorithms and order the list by the ranking and by the algorithms allocated kingdom. Output
# the results into a file (results.txt).
# This script does some screen scraping purely in the name of science.
# Never Use It. (use my results) Run it once, collected the results, and analyze forever.


# Development Sources (i hacked this program together):
# Screen Scraping Google with Hpricot and Watir: http://refactormycode.com/codes/673-screen-scraping-google-with-hpricot-and-watir
# Scraping with style: scrAPI toolkit for Ruby: http://labnotes.org/2006/07/11/scraping-with-style-scrapi-toolkit-for-ruby/
# How to get the number of results found for a keyword in google: http://stackoverflow.com/questions/1809976/how-to-get-the-number-of-results-found-for-a-keyword-in-google
# Google AJAX Search API + Ruby: http://chris.mowforth.com/post/146052675/google-ajax-search-api-ruby
# Exploring the Google AJAX Search API: http://sophsec.com/research/exploring_ajax_search.html
# Flash and other Non-Javascript Environments (search API): http://code.google.com/apis/ajaxsearch/documentation/#fonje
# Flash and other Non-Javascript Environments (search docs): http://code.google.com/apis/ajaxsearch/documentation/reference.html#_intro_fonje
# Net::HTTP http://ruby-doc.org/stdlib/libdoc/net/http/rdoc/classes/Net/HTTP.html
# Sample code.Python. Perl. Language Ajax api. Post method. 5000. api limit http://osdir.com/ml/GoogleAJAXAPIs/2009-05/msg00118.html
# Hpricot Basics: http://wiki.github.com/whymirror/hpricot/hpricot-basics


require 'rubygems'
module JSON
  VARIANT_BINARY = false # hack - god knows why i need it (I get a VARIANT_BINARY undefined error)
end
require 'json'
require 'net/http'
require 'hpricot'

# monkey patch for float
class Float
  def round_to(x)
    (self * 10**x).round.to_f / 10**x
  end
end

# Google REST (ajax) API: http://code.google.com/apis/ajaxsearch/documentation/#fonje
def get_approx_google_web_results(keyword)
  http = Net::HTTP.new('ajax.googleapis.com', 80)
  header = {'content-type'=>'application/x-www-form-urlencoded', 'charset'=>'UTF-8'}
  path = "/ajax/services/search/web?v=1.0&q=#{keyword}&rsz=small"
  resp, data = http.request_get(path, header)
  rs = JSON.parse(data)
  return 0 if rs.nil? or rs['responseData'].nil? or rs['responseData']['cursor'].nil? or rs['responseData']['cursor']['estimatedResultCount'].nil?
  return rs['responseData']['cursor']['estimatedResultCount']
end

# Google REST (ajax) API: http://code.google.com/apis/ajaxsearch/documentation/#fonje
def get_approx_google_book_results(keyword)
  http = Net::HTTP.new('ajax.googleapis.com', 80)
  header = {'content-type'=>'application/x-www-form-urlencoded', 'charset'=>'UTF-8'}
  path = "/ajax/services/search/books?v=1.0&q=#{keyword}&rsz=small"
  resp, data = http.request_get(path, header)
  rs = JSON.parse(data)
  return 0 if rs.nil? or rs['responseData'].nil? or rs['responseData']['cursor'].nil? or rs['responseData']['cursor']['estimatedResultCount'].nil?
  return rs['responseData']['cursor']['estimatedResultCount']
end

# http://scholar.google.com.au/scholar?q=%22genetic+algorithm%22&hl=en&btnG=Search&as_sdt=2001&as_sdtp=on
def get_approx_google_scholar_results(keyword)
  http = Net::HTTP.new('scholar.google.com.au', 80)
  header = {}
  path = "/scholar?q=#{keyword}&hl=en&btnG=Search&as_sdt=2001&as_sdtp=on"
  resp, data = http.request_get(path, header)
  doc = Hpricot(data)
  rs = doc.search("//td[@bgcolor='#dcf6db']/font/b")
  return 0 if rs.nil? or rs.size!=5 # no results or unexpected results
  rs = rs[3].inner_html.gsub(',', '') # strip comma    
  return rs
end

# http://springerlink.com/home/main.mpx
# http://springerlink.com/content/?k=%22genetic+algorithm%22
def get_approx_springer_results(keyword)
  http = Net::HTTP.new('springerlink.com', 80)
  header = {}
  path = "/content/?k=#{keyword}"
  resp, data = http.request_get(path, header)
  doc = Hpricot(data)
  rs = doc.search("//span[@id='ctl00_PageSidebar_ctl01_Sidebarplaceholder1_StartsWith_ResultsCountLabel']")
  return 0 if rs.nil? # no results
  rs = rs.first.inner_html
  rs = rs.split(' ').first.gsub(',', '') # strip comma
  return rs
end

# http://www.scirus.com/
# http://www.scirus.com/srsapp/search?q=%22genetic+algorithm%22&t=all&sort=0&g=s
def get_approx_scirus_results(keyword)
  http = Net::HTTP.new('scirus.com', 80)
  header = {'User-Agent'=>'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.1) Gecko/20060111 Firefox/1.5.0.1'}
  path = "/srsapp/search?q=#{keyword}&t=all&sort=0&g=s"
  resp, data = http.request_get(path, header)
  return 0 if data.include?("Sorry, your search has not produced any results.")
  doc = Hpricot(data)
  rs = doc.search("//div[@class='headerAllText']")
  return 0 if rs.nil? # no results
  rs = rs.first.inner_html
  rs = rs.split(' ')[2].gsub(',', '') # strip comma
  return rs
end


# http://ieeexplore.ieee.org/search/freesearchresult.jsp?history=yes&queryText=%28~~genetic+algorithm~~%29&imageField.x=0&imageField.y=0
def get_approx_ieee_results(keyword)
  http = Net::HTTP.new('ieeexplore.ieee.org', 80)
  header = {}
  keyword = keyword.gsub("%22", "~~") #special handling
  path = "/search/freesearchresult.jsp?history=yes&queryText=%28#{keyword}%29&imageField.x=0&imageField.y=0"
  resp, data = http.request_get(path, header)
  doc = Hpricot(data)
  rs = doc.search("//td[@class='bodyCopyBlackLargeSpaced']/strong")
  return 0 if rs.nil? # no results
  rs = rs[1].inner_html
  return rs
end

def get_results(algorithm_name)  
  # spaces to plus, lowercase, quote using %22 - good for all search services used
  keyword = algorithm_name.gsub(/ /, "+")
  keyword = "%22#{keyword.downcase}%22"
  
  # 
  # dear future self, you can keep adding measures here and the pipeline should make use of them
  # 
  
  scores = []
  # Google Web Search
  scores << get_approx_google_web_results(keyword)
  # Google Book Search
  scores << get_approx_google_book_results(keyword)
  # Google Scholar Search
  scores << get_approx_google_scholar_results(keyword)
  # Springer Article Search
  scores << get_approx_springer_results(keyword)
  # Scirus Search
  scores << get_approx_scirus_results(keyword)
  # IEEE Search
  scores << get_approx_ieee_results(keyword)
  
  return scores
end

def timer
  start = Time.now
  yield
  Time.now - start
end

# The Fisher-Yates shuffle: http://en.wikipedia.org/wiki/Knuth_shuffle
def shuffle!(array)
  n = array.length
  for i in 0...n
    r = rand(n-i) + i
    array[r], array[i] = array[i], array[r]
  end
  return array
end

def generate_results
  if File.exists?("./results.txt") 
    puts "Results already available, not generating."
  else
    puts "No existing results, generating...(will take a while - upto 10sec per algorithm)"
    algorithms_list = IO.readlines("./algorithms.txt")
    # remove any bias in the way the file was put together (exposes sorting problems later)
    shuffle!(algorithms_list)
    results = ""
    algorithms_list.each_with_index do |line, i|
      algorithm_name, scores = line.split(',')[1].strip, nil
      clock = timer{scores = get_results(algorithm_name)}
      results << "#{line.strip},#{scores.join(",")}\n"
      puts(" > #{(i+1)}/#{algorithms_list.size}: #{algorithm_name}, #{clock.to_i} seconds")
    end
    File.open("./results.txt", "w") { |f| f.printf(results) }
  end
end

def normalize_results
  if File.exists?("./results_normalized.txt") 
    puts "Skipping normalization results, already exists"  
  else
    puts "Outputting normalization results..."
    raw = IO.readlines("./results.txt")
    algorithms_list = []
    raw.each { |line| algorithms_list << line.split(',')}
    normalized_scores = Array.new(algorithms_list[0].length-2) {|i| [10000.0, 0.0]} 
    # calculate min/max
    algorithms_list.each do |row|      
      row[2..row.length-1].each_with_index do |v, i|
        normalized_scores[i][0] = v if v.to_f < normalized_scores[i][0].to_f
        normalized_scores[i][1] = v if v.to_f > normalized_scores[i][1].to_f
      end
    end
    # normalize scores
    results = ""
    algorithms_list.each do |row|
      scores = []
      row[2..row.length-1].each_with_index do |v,i|      
        # (v-min)/(max-min) 
        scores << (v.to_f - normalized_scores[i][0].to_f) / ( normalized_scores[i][1].to_f - normalized_scores[i][0].to_f)
      end
      # calculate rank
      rank = scores.inject(0.0) {|sum, n| sum + n.to_f } 
      # results << "#{row[0]},#{row[1]},#{scores.join(",")},#{rank}\n"
      results << "#{row.join(",").strip},#{rank.round_to(3)}\n"
    end  
    File.open("./results_normalized.txt", "w") { |f| f.printf(results) }
  end
end


# organized results, suitable for presenting in latex tables
def generate_organized_results  
  if File.exists?("./results_organized.txt") 
    puts "Skipping organized results, already exists"  
  else
    puts "Outputting organized results"
    # prepare data structures
    raw = IO.readlines("./results_normalized.txt")
    # array of arrays
    algorithms_list = []
    raw.each { |line| algorithms_list<<line.split(',')}    
    # hash of arrays by kingdom
    data = {}
    algorithms_list.each do |row|
      row.collect! {|v| v.strip.downcase}
      data[row[0]] = [] if !data.has_key?(row[0])
      data[row[0]] << row[1..row.length-1]
    end
    # organize    
    results = ""
    data.each_pair do |key, value| 
      results << "\nKingdom: #{key} (#{value.size})\n"
      value.sort {|x,y| y[y.length-1].to_f <=> x[x.length-1].to_f}.each { |v| results << "#{v.join(" & ")} \\\\\n" }
    end
    # top 10 overall
    results << "\nKingdom: Top 10 Algorithms (10)\n"
    top = 0
    algorithms_list.sort {|x,y| y[y.length-1].to_f <=> x[x.length-1].to_f}.each_with_index do |v, i|
      break if top>=10 # bounded
      results << "#{v.join(" & ")} \\\\\n"
      top += 1
    end
    File.open("./results_organized.txt", "w") { |f| f.printf(results) }
  end
end


def display_pretty_results
  # prepare data structures
  raw = IO.readlines("./results_normalized.txt")
  # array of arrays
  algorithms_list = []
  raw.each { |line| algorithms_list<<line.split(',')}
  # hash of arrays by kingdom
  data = {}
  algorithms_list.each do |row|
    row.collect! {|v| v.strip}
    data[row[0]] = [] if !data.has_key?(row[0])
    data[row[0]] << row[1..row.length-1]
  end
  puts "Generating statistics..."
  puts "------------------------------"
  # overall top algorithms
  puts "Top 10 Algorithms, Overall:"
  top = 0
  algorithms_list.sort {|x,y| y[y.length-1].to_f <=> x[x.length-1].to_f}.each_with_index do |v, i|
    break if top>=10 # bounded
    puts "#{(top+1)} #{v[1]}"
    top += 1
  end
  puts "------------------------------"
  # process each kingdom
  data.each_pair do |key, value| 
    # print top 10
    puts "Top 10 Algorithms for #{key}: (of #{value.size})"
    value.sort {|x,y| y[y.length-1].to_f <=> x[x.length-1].to_f}.each_with_index do |v, i|
      break if i>=10
      puts "#{(i+1)} #{v[0]}"
    end
    puts "------------------------------"
  end
end


# 
#  main execution
# 

puts "Starting..."
# generate results
generate_results
# normalize results and calculate scores
normalize_results
# organize results for use in reports
generate_organized_results
# display pretty results to cmd line
display_pretty_results
puts "Done!"
