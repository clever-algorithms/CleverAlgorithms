class HomeController < ApplicationController
  
  def index
    @algorithm = Algorithm.released.first(:order=>"RANDOM()")
  end
  
  def about
    
  end
  
  def help
    
  end
  
end
