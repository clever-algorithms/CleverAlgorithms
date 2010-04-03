module Admin::AlgorithmsHelper
  
  def date_difference_days(date_time)    
    days = (DateTime.now - date_time.to_time.to_date).to_i
    return "today" if days == 0
    return days
  end
  
end
