class Algorithm < ActiveRecord::Base
  
  # validation
  validates_format_of :name, :with => /\A[a-zA-Z0-9\ \-]+\Z/, 
    :message=>"Algorithm name must be text/numbers/space/hyphen."
  validates_uniqueness_of :name
  
    
  # scopes
  named_scope :ordered_by_name, :order=>"name ASC"
  named_scope :released, :conditions=>['released=?', true]
  named_scope :unreleased, :conditions=>['released=?', false]
  named_scope :book, :conditions=>['book=?', true]
  named_scope :random, :order=>"RANDOM()"
 
  # associations
  has_many :messages
  
  
  def to_param  # overridden
    name.gsub(/ /, '+')    
  end
  
  def has_unaddressed_msgs?
    return messages.all_unaddressed.count > 0
  end
  
  def self.first_by_name(name)
    name = name.gsub('+', ' ')
    return Algorithm.first(:conditions=>['name=?', name])
  end
  
  def self.count_updated_within_days_ago(days)
    date = (Date.today - days).to_time.utc
    return Algorithm.count(:all, :conditions=>['updated_at>?',date])
  end
  
  
  def completed()
    return false if aliases.blank?
    return false if taxonomy.blank?
    return false if strategy.blank?
    # return false if procedure.blank?
    return false if heuristics.blank?
    return false if code.blank?
    return false if code_file.blank?
    return false if references.blank?
    return false if bibliography.blank?
    # return false if web.blank?
    
    return true
  end
  
end
