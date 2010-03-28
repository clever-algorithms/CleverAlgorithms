class BookController < ApplicationController
  
  def index
    
  end
  
  
  def create
    @email = Email.new(params[:email])

    respond_to do |format|
      if @email.save
        flash[:notice] = "Thanks, you will be notified when the book launches."
        format.html { redirect_to(:action=>"index") }
        # format.xml  { render :xml => @algorithm, :status => :created, :location => @algorithm }
      else
        format.html { render :action => "index" }
        # format.xml  { render :xml => @algorithm.errors, :status => :unprocessable_entity }
      end
    end
  end
  
end
