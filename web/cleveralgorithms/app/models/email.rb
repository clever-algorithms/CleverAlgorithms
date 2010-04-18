class Email < ActiveRecord::Base
  
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create
  
  def self.count_created_within_days_ago(days)
    date = (Date.today - days).to_time.utc
    return Email.count(:all, :conditions=>['updated_at>?',date])
  end
  
end
