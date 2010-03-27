# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  
  # the name of the website used in views
  def site_name
    "Clever Algorithms"
  end
  
  # the url of the site when displayed in the views
  def site_url
    "http://www.CleverAlgorithms.com"
  end
  
  def book_title
    "Clever Algorithms: Modern Artificial Intelligence Recipes"
  end
  
  # title convention used in the sute
  def title(page_title=nil)
    if !page_title.nil?
	    content_for(:title) { "#{page_title} - CleverAlgorithms.com" }
	  else
	    content_for(:title) { "#{site_name}" }
	  end
	end
	
end
