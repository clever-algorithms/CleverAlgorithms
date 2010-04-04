# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # jason brownlee email
  # used on copyright, etc
  def jason_email
    "jasonb@CleverAlgorithms.com"
  end
  
  # the name of the website used in views
  def site_name
    "Clever Algorithms"
  end
  
  # the url of the site when displayed in the views
  def site_url
    "http://www.CleverAlgorithms.com"
  end
  
  # url to the dev site
  def development_url
    "http://github.com/jbrownlee/CleverAlgorithms"
  end
  
  def book_title
    "Clever Algorithms: Modern Artificial Intelligence Recipes"
  end
  
  def book_author
    "Jason Brownlee"
  end
  
  # title convention used in the sute
  def title(page_title=nil)
    if !page_title.nil?
	    content_for(:title) { "#{page_title} - CleverAlgorithms.com" }
	  else
	    content_for(:title) { "#{site_name}" }
	  end
	end
	
	def popular_algorithms(limit=5)
	  Algorithm.all(:order=>"RANDOM()", :limit=>limit)
	end
	
	def updated_algorithms(limit=5)
	  Algorithm.all(:order=>"updated_at DESC", :limit=>limit)
	end
	
	def snippet(thought, wordcount) 
	  thought.split[0..(wordcount-1)].join(" ") +(thought.split.size > wordcount ? "..." : "") 
	end

  def lazy_algorithm_link(name)
    link_to name, algorithm_url(name)
  end

end
