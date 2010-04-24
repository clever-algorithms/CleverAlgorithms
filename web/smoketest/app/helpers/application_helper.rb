# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def book_author
    "Dr Jason Brownlee, Ph.D."
  end
  
  def site_name
    "Clever Algorithms"
  end
  
  def site_url
    "http://www.CleverAlgorithms.com"
  end
  
  def book_name_full
    "#{book_title}: #{book_subtitle}"
  end
  
  def book_title
    "Clever Algorithms"
  end
  
  def book_subtitle
    "Modern Artificial Intelligence Recipes"
  end
  
  def book_dev_url
    "http://github.com/jbrownlee/CleverAlgorithms"
  end
  
end
