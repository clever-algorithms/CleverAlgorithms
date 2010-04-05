class MessagesController < ApplicationController
  
  before_filter :load_algorithm

  def load_algorithm
    redirect_to(algorithms_path) if params[:algorithm_id].nil?
    name = params[:algorithm_id].gsub('+', ' ')
    @algorithm = Algorithm.first(:conditions=>['name=?', name])
    if @algorithm.nil?
      flash[:notice] = "Unknown algorithm '#{name}', perhaps suggest it!"
      redirect_to(algorithms_path) 
      return
    end
  end
  
  # GET /messages
  # GET /messages.xml
  # def index
  #   @messages = Message.all
  # 
  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.xml  { render :xml => @messages }
  #   end
  # end

  # GET /messages/1
  # GET /messages/1.xml
  # def show
  #   @message = Message.find(params[:id])
  # 
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.xml  { render :xml => @message }
  #   end
  # end

  # GET /messages/new
  # GET /messages/new.xml
  def new
    @message = Message.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @message }
    end
  end

  # GET /messages/1/edit
  # def edit
  #   @message = Message.find(params[:id])
  # end

  # POST /messages
  # POST /messages.xml
  def create    
    params[:message][:algorithm] = @algorithm
    @message = Message.new(params[:message])
    respond_to do |format|
      if @message.save
        flash[:notice] = 'Message sent successfully.'
        format.html {redirect_to(@algorithm) }
        format.xml  { render :xml => @message, :status => :created, :location => @message }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /messages/1
  # PUT /messages/1.xml
  # def update
  #   @message = Message.find(params[:id])
  # 
  #   respond_to do |format|
  #     if @message.update_attributes(params[:message])
  #       flash[:notice] = 'Message was successfully updated.'
  #       format.html { redirect_to(@message) }
  #       format.xml  { head :ok }
  #     else
  #       format.html { render :action => "edit" }
  #       format.xml  { render :xml => @message.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /messages/1
  # DELETE /messages/1.xml
  # def destroy
  #   @message = Message.find(params[:id])
  #   @message.destroy
  # 
  #   respond_to do |format|
  #     format.html { redirect_to(messages_url) }
  #     format.xml  { head :ok }
  #   end
  # end
end
