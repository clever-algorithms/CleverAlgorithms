class Email < ActiveRecord::Base
  
  # validation
  validates_format_of :email, :with=> /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on=>:save, :message=>"Please provide a valid email address."


  
end
