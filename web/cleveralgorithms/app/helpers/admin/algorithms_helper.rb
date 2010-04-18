module Admin::AlgorithmsHelper
  
  def date_difference_days(date_time)    
    days = (DateTime.now - date_time.to_time.to_date).to_i
    return "today" if days == 0
    return "#{days} days ago" 
  end
  
  
  def algorithm_messages_field(algorithm)
    total = algorithm.messages.count
    return "0/0" if total == 0
    unaddressed = algorithm.messages.all_unaddressed.count    
    link_text = "#{unaddressed}/#{total}"
    return link_to(link_text, admin_algorithm_messages_path(algorithm)) 
  end
  
end
