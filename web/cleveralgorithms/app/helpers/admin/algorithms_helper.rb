module Admin::AlgorithmsHelper
  
  def date_difference_days(date_time)
    return (DateTime.now - date_time.to_time.to_date).to_i
    # ((Date.today - a.created_at.to_time.to_date)/60/60/24)
  end
  
end
