class HomeController < ApplicationController
  
  def index
    @algorithm = random_algorithm
  end
  
  def about
    
  end
  
  
  private 
  
  def random_algorithm
    # Algorithm.first(:order=>"RANDOM()", :limit=>1)
    Algorithm.find_by_name("Genetic Algorithm")
	end
  
end
