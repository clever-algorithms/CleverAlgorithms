module Admin::PanelHelper
  
  def total_algorithms
    Algorithm.count
  end
  
  def total_email_notifications
    Email.count
  end
  
  def total_email_notifications_last_day
    Email.count(:conditions=>"created_at>'#{1.day.ago.to_date.to_s(:db)}'")
  end
  
  def total_email_notifications_last_week
    Email.count(:conditions=>"created_at>'#{7.days.ago.to_date.to_s(:db)}'")
  end
  
end
