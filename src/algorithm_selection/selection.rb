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
# Never Use It. (use my results) I Ran it once, collected the results, and analyze forever.


# Development Sources (i hacked this together):
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

def get_results(algorithm_name)  
  # spaces to plus, quote using %22 - good for all search services used
  keyword = algorithm_name.gsub(/ /, "+")
  keyword = "%22#{keyword}%22"
  
  scores = {}
  # Google Web Search
  scores['google_web'] = get_approx_google_web_results(keyword)
  # Google Book Search
  scores['google_book'] = get_approx_google_book_results(keyword)
  # Google Scholar Search
  scores['google_scholar'] = get_approx_google_scholar_results(keyword)
  # Springer Article Search
  scores['springer'] = get_approx_springer_results(keyword)
  # Scirus Search
  scores['scirus'] = get_approx_scirus_results(keyword)
  
  return scores
end

def timer
  start = Time.now
  yield
  Time.now - start
end

def rank_algorithm(name)
  # score algorithm
  scores = nil
  scores=get_results(name)
  # rank algorithm
  rank = 0
  # weighted sum, insert factors and exponents, it's a party
  scores.each_pair do |key, value| 
    # boost 'academic' sources
    if ['google_scholar', 'springer', 'scirus', 'google_book'].include?(key) 
      rank += (value.to_f * 1.5);
    else
      rank += (value.to_f * 1.0);
    end    
  end  
  return rank
end

# rank testing
# rank = rank_algorithm("artificial intelligence")
# puts "rank: #{rank}"
# exit

# check if results exist, generate if not
if File.exists?("./results.txt") 
  puts "Results already available, not generating."
else
  puts "No existing results, generating...(will take a while - 10sec per algorithm)"
  # load the list of algorithms
  algorithms_list = IO.readlines("./algorithms.txt")
  # rank
  results = []
  algorithms_list.each do |line|
    algorithm_name, rank = line.split(',')[1].strip, 0
    clock = timer{rank = rank_algorithm(algorithm_name)}
    puts(" > #{algorithm_name}, #{clock.to_i} seconds, rank=#{rank}")
  end
  # output results
  
end


