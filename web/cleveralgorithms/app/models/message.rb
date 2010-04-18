class Message < ActiveRecord::Base
  
  # validation
  validates_format_of :email, :with=> /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on=>:save, :unless=>:email_not_specified?
  validates_presence_of :msg, :message=>"msg must be provided"
  
  # associations
  belongs_to :algorithm
  
  # named scopes
  named_scope :all_addressed, :conditions=>['addressed=?', true]
  named_scope :all_unaddressed, :conditions=>['addressed=?', false]
  
  def email_not_specified?()
    return (email.nil? or email.blank?)
  end
   

  
end
