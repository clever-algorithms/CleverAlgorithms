# Book Field
# Copyright (C) 2008 Jason Brownlee
# 
# Change History
# 2008/12/11  JB  Created


# Properties
# - diversity         (subjective)
# - popularity        (number of results in a google search)
# - classical         (relative inception date)
# - state of the art  (relative inception date)


require 'rubygems'
require 'cgi'
require 'open-uri'
require 'hpricot'

# based on: http://snippets.dzone.com/posts/show/4133
q = %w{genetic algorithm}.map { |w| CGI.escape(w) }.join("+")
url = "http://www.google.com/search?q=#{q}"
doc = Hpricot(open(url).read)
# lucky_url = (doc/"div[@class='g'] a").first["href"]
# system 'open #{lucky_url}'
puts doc
# puts (doc/"a[@swrnum='swrnum']").first

