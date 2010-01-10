# selection.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. All Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

# Description:
# Enumerate a listing of algorithms (list.txt) and locate the approximate number of results
# from a number of different search engines and search domains (google). Rank the listing of 
# algorithms and order the list by the ranking and by the algorithms allocated kingdom. Output
# the results into a file (results.txt).


# sources:
# Screen Scraping Google with Hpricot and Watir: http://refactormycode.com/codes/673-screen-scraping-google-with-hpricot-and-watir
# Scraping with style: scrAPI toolkit for Ruby: http://labnotes.org/2006/07/11/scraping-with-style-scrapi-toolkit-for-ruby/
# How to get the number of results found for a keyword in google: http://stackoverflow.com/questions/1809976/how-to-get-the-number-of-results-found-for-a-keyword-in-google
# Google AJAX Search API + Ruby: http://chris.mowforth.com/post/146052675/google-ajax-search-api-ruby
# Exploring the Google AJAX Search API: http://sophsec.com/research/exploring_ajax_search.html
# Flash and other Non-Javascript Environments (search API): http://code.google.com/apis/ajaxsearch/documentation/#fonje
# Flash and other Non-Javascript Environments (search docs): http://code.google.com/apis/ajaxsearch/documentation/reference.html#_intro_fonje
# Net::HTTP http://ruby-doc.org/stdlib/libdoc/net/http/rdoc/classes/Net/HTTP.html
# Sample code.Python. Perl. Language Ajax api. Post method. 5000. api limit http://osdir.com/ml/GoogleAJAXAPIs/2009-05/msg00118.html


require 'rubygems'

# hack - god knows why i need it
module JSON
  VARIANT_BINARY = false
end
require 'json'
require 'net/http'


# http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=Paris%20Hilton
def get_approx_google_web_results(keyword)
  http = Net::HTTP.new('ajax.googleapis.com', 80)
  header = {'content-type'=>'application/x-www-form-urlencoded', 'charset'=>'UTF-8'}
  path = "/ajax/services/search/web?v=1.0&q=#{keyword}&rsz=small"
  resp, data = http.request_get(path, header)
  return JSON.parse(data)
end

def get_approx_google_book_results(keyword)
  http = Net::HTTP.new('ajax.googleapis.com', 80)
  header = {'content-type'=>'application/x-www-form-urlencoded', 'charset'=>'UTF-8'}
  path = "/ajax/services/search/books?v=1.0&q=#{keyword}&rsz=small"
  resp, data = http.request_get(path, header)
  return JSON.parse(data)
end

def get_results(algorithm_name)
  keyword = algorithm_name.gsub(/ /, "+")
  scores = []

  # google web
  web_rs = get_approx_google_web_results(keyword)
  scores << web_rs['responseData']['cursor']['estimatedResultCount']
  # google book
  web_rs = get_approx_google_book_results(keyword)
  scores << web_rs['responseData']['cursor']['estimatedResultCount']
  # google scholar 
  # TODO
  
  return scores
end


# testing
puts get_results("genetic algorithm")
