class HomeController < ApplicationController
  
  def index
    @algorithm = random_algorithm
  end
  
  def about
    
  end
  
  
  private 
  
  def random_algorithm
	  Algorithm.first(:order=>"RANDOM()", :limit=>1)
	end
  
end
