class Admin::AdminController < ApplicationController

  # http://stackoverflow.com/questions/107674/backend-administration-in-rails

  before_filter :authenticate

  
  private
  # todo lookup in database
  def authenticate
    authenticate_or_request_with_http_basic { |u, p| u == "admin" && p == "1234" }
  end
  
end
