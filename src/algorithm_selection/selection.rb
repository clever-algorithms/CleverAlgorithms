# selection.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
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


require 'selection_lib'

# this is the original list for the tech report
# ALGORITHMS_LIST = "algorithms.txt"

# dynamically updated based on names found in papers/books
ALGORITHMS_LIST = "algorithms2.txt"

ALGORITHM_RESULTS = "results.txt"
NORMALIZED_RESULTS = "results_normalized.txt"
ORGANIZED_RESULTS = "results_organized.txt"

# monkey patch for float
class Float
  def round_to(x)
    (self * 10**x).round.to_f / 10**x
  end
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
  # updated to only calculate for those new additions to the list (avoid spamming google)
  # for accurate results, re-run all queries (delete results.txt)
  
  algorithms_list = IO.readlines(ALGORITHMS_LIST)
  # remove any bias in the way the file was put together (exposes sorting problems later)
  shuffle!(algorithms_list)
  result_algorithm_names_list = []
  if File.exists?(ALGORITHM_RESULTS) 
    raw = IO.readlines(ALGORITHM_RESULTS)
    raw.each { |line| result_algorithm_names_list << line.split(',')[1].strip.downcase}
  end
  
  # process algorithms
  results = ""
  algorithms_list.each_with_index do |line, i|
    algorithm_name, scores = line.split(',')[1].strip, nil
    # only query if not already queried
    if !result_algorithm_names_list.include?(algorithm_name.downcase)
      clock = timer{scores = get_results(algorithm_name)}
      results << "#{line.strip},#{scores.join(",")}\n"
      puts(" > #{(i+1)}/#{algorithms_list.size}: #{algorithm_name}, #{clock.to_i} seconds")
    else
      puts(" > #{(i+1)}/#{algorithms_list.size}: skipping #{algorithm_name}")
    end
  end
  
  if results.length > 1
    # append if exists, or write
    File.open(ALGORITHM_RESULTS, "a") { |f| f.printf(results) }
  end
end

def normalize_results
  puts "Outputting normalization results..."
  raw = IO.readlines(ALGORITHM_RESULTS)
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
    results << "#{row.join(",").strip},#{rank.round_to(3)}\n"
  end  
  File.open(NORMALIZED_RESULTS, "w") { |f| f.printf(results) }
end


# organized results, suitable for presenting in latex tables
def generate_organized_results  
  puts "Outputting organized results"
  # prepare data structures
  raw = IO.readlines(NORMALIZED_RESULTS)
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
  File.open(ORGANIZED_RESULTS, "w") { |f| f.printf(results) }
end


def display_pretty_results
  # prepare data structures
  raw = IO.readlines(NORMALIZED_RESULTS)
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
