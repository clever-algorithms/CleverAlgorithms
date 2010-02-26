# selection_lib.rb

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

# 
# Library functions for getting the approximate number of results for a given well-formed query
# All queries are expected in the form: %22genetic+algorithm%22


require 'rubygems'
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

# updated 20100226
# http://ieeexplore.ieee.org/search/freesearchresult.jsp?newsearch=true&queryText=.QT.genetic+algorithm.QT.&x=0&y=0
# http://ieeexplore.ieee.org:80/search/freesearchresult.jsp?reload=true&amp;newsearch=true&amp;queryText=.QT.geneticPLSalgorithm.QT.&amp;x=0&amp;y=0
def get_approx_ieee_results(keyword)
  http = Net::HTTP.new('ieeexplore.ieee.org', 80)
  header = {}
  keyword = keyword.gsub("%22", ".QT.") #special handling
  keyword = keyword.gsub("+", "PLS") #special handling
  path = "/search/freesearchresult.jsp?reload=true&amp;newsearch=true&amp;queryText=#{keyword}&amp;x=0&amp;y=0"
  resp, data = http.request_get(path, header)
  doc = Hpricot(data)
  rs = doc.search("//span[@class='display-status']")
  return 0 if rs.nil? # no results
  rs = rs.first.inner_html
  rs = rs.strip.split(' ')[5]
  return rs
end