class BookController < ApplicationController
  
  def index
  end
  
  def create
    @email = Email.new(params[:email])
    respond_to do |format|
      if @email.save       
        flash[:notice] = 'Thank-you, we hope to be notifying you soon!'
        format.html { redirect_to(root_path) }
      else
        format.html { render :controller=>"book", :action => "index" }
      end
    end
  end

  private
  


end
