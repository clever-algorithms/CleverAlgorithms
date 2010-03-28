class Algorithm < ActiveRecord::Base
  
  # validation
  validates_format_of :name, :with => /\A[a-zA-Z0-9\ ]+\Z/, 
    :message=>"Algorithm name must be text or numbers and spaces."
  validates_uniqueness_of :name
  validates_presence_of :aliases, :message=>"aliases must be provided"
  validates_presence_of :taxonomy, :message=>"taxonomy must be provided"
  # validates_presence_of :inspiration,
  # validates_presence_of :metaphor,
  validates_presence_of :strategy, :message=>"strategy must be provided"
  validates_presence_of :procedure, :message=>"procedure must be provided"
  validates_presence_of :heuristics, :message=>"heuristics must be provided"
  validates_presence_of :code, :message=>"code must be provided"
  validates_presence_of :code_file, :message=>"code_file must be provided"
  validates_presence_of :references, :message=>"references must be provided"
  validates_presence_of :bibliography, :message=>"bibliography must be provided"
  validates_presence_of :web, :message=>"web must be provided"
  
  def to_param  # overridden
    name.sub(' ', '+')
  end
  
end
