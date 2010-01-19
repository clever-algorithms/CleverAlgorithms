# selection.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

# Description:
# todo

# Based on the script used to select algorithms for description in the Clever Algorithms project.


require 'rubygems'
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


def get_results(algorithm_name)  
  # spaces to plus, lowercase, quote using %22 - good for all search services used
  keyword = algorithm_name.gsub(/ /, "+")
  keyword1 = "%22#{keyword.downcase}%22"
  keyword2 = "%22#{keyword.downcase}%22+optimization"
  
  # 
  # dear future self, you can keep adding measures here and the pipeline should make use of them
  # 
  
  scores = []
  # Google Web Search
  scores << get_approx_google_web_results(keyword1)
  # Google Book Search
  scores << get_approx_google_book_results(keyword1)
  # Google Scholar Search
  scores << get_approx_google_scholar_results(keyword1)
  
  # Google Web Search
  scores << get_approx_google_web_results(keyword2)
  # Google Book Search
  scores << get_approx_google_book_results(keyword2)
  # Google Scholar Search
  scores << get_approx_google_scholar_results(keyword2)
  
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
    languages_list = IO.readlines("./languages.txt")
    # remove any bias in the way the file was put together (exposes sorting problems later)
    shuffle!(languages_list)
    results = ""
    languages_list.each_with_index do |line, i|
      name, scores = line.strip, nil
      clock = timer{scores = get_results(name)}
      results << "#{line.strip},#{scores.join(",")}\n"
      puts(" > #{(i+1)}/#{languages_list.size}: #{name}, #{clock.to_i} seconds")
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
    languages_list = []
    raw.each { |line| languages_list << line.split(',')}
    normalized_scores = Array.new(languages_list[0].length-1) {|i| [10000.0, 0.0]} 
    # calculate min/max
    languages_list.each do |row|      
      row[1..row.length-1].each_with_index do |v, i|
        normalized_scores[i][0] = v if v.to_f < normalized_scores[i][0].to_f
        normalized_scores[i][1] = v if v.to_f > normalized_scores[i][1].to_f
      end
    end
    # normalize scores
    results = ""
    languages_list.each do |row|
      scores = []
      row[1..row.length-1].each_with_index do |v,i|      
        # (v-min)/(max-min) 
        scores << (v.to_f - normalized_scores[i][0].to_f) / ( normalized_scores[i][1].to_f - normalized_scores[i][0].to_f)
      end
      # calculate rank
      rank = scores.inject(0.0) {|sum, n| sum + n.to_f } 
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
    languages_list = []
    raw.each { |line| languages_list<<line.split(',')}    
    # order by score
    results = ""
    results << "\nLanguages by rank (#{languages_list.size})\n"
    languages_list.sort {|x,y| y[y.length-1].to_f <=> x[x.length-1].to_f}.each_with_index do |v, i|
      results << "#{v.join(" & ")} \\\\\n"
    end
    File.open("./results_organized.txt", "w") { |f| f.printf(results) }
  end
end


def display_pretty_results
  # prepare data structures
  raw = IO.readlines("./results_normalized.txt")
  # array of arrays
  languages_list = []
  raw.each { |line| languages_list<<line.split(',')}
  puts "Generating statistics..."
  puts "------------------------------"
  # ordered by score
  puts "Top Laugages, Overall:"
  languages_list.sort {|x,y| y[y.length-1].to_f <=> x[x.length-1].to_f}.each_with_index do |v, i|
    puts "#{(i+1)} #{v[0]}"
  end
  puts "------------------------------"
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
