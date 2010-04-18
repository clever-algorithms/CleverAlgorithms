class Admin::MessagesController < Admin::AdminController
  
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
  def index
    @messages = @algorithm.messages
  
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @messages }
    end
  end

  # GET /messages/1
  # GET /messages/1.xml
  def show
    @message = Message.find(params[:id])
  
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @message }
    end
  end


  # GET /messages/1/edit
  def edit
    @message = @algorithm.messages.find(params[:id])
  end

  # POST /messages
  # POST /messages.xml
  # def create    
  #   params[:message][:algorithm] = @algorithm
  #   @message = Message.new(params[:message])
  #   respond_to do |format|
  #     if @message.save
  #       flash[:notice] = "Thanks again, your suggestion will be read ASAP by our team of PhDs."
  #       format.html {redirect_to(@algorithm) }
  #       format.xml  { render :xml => @message, :status => :created, :location => @message }
  #     else
  #       format.html { render :action => "new" }
  #       format.xml  { render :xml => @message.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end

  # PUT /messages/1
  # PUT /messages/1.xml
  def update
    @message = @algorithm.messages.find(params[:id])
  
    respond_to do |format|
      if @message.update_attributes(params[:message])
        flash[:notice] = 'Message was successfully updated.'
        format.html { redirect_to(admin_algorithm_messages_url(@algorithm)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.xml
  def destroy
    @message = @algorithm.messages.find(params[:id])
    @message.destroy
  
    respond_to do |format|
      format.html { redirect_to(admin_algorithm_messages_url(@algorithm)) }
      format.xml  { head :ok }
    end
  end
  
end
