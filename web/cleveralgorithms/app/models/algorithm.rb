class Algorithm < ActiveRecord::Base
  
  # validation
  validates_format_of :name, :with => /\A[a-zA-Z0-9\ \-]+\Z/, 
    :message=>"Algorithm name must be text/numbers/space/hyphen."
  validates_uniqueness_of :name
  
    
  # scopes
  named_scope :ordered_by_name, :order=>"name ASC"
  named_scope :released, :conditions=>['released=?', true]
  named_scope :random, :order=>"RANDOM()"
 
  # associations
  has_many :messages
  
  
  def to_param  # overridden
    name.gsub(/ /, '+')    
  end
  
  
 
  
end
