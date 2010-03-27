class AlgorithmsController < ApplicationController
  # GET /algorithms
  # GET /algorithms.xml
  def index
    @algorithms = Algorithm.all(:order=>"name ASC")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @algorithms }
    end
  end

  # GET /algorithms/1
  # GET /algorithms/1.xml
  def show
    name = params[:name].gsub('+', ' ')
    @algorithm = Algorithm.find_by_name(name)
    if @algorithm.nil?
      @algorithm = Algorithm.find(name)
      # redirect_to(:action=>"show", :name=>@algorithm.name)
    end
    

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @algorithm }
    end
  end

end
