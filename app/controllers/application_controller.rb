class ApplicationController < ActionController::Base
  protect_from_forgery
  around_filter :shopify_session

  def render_success
    render :file => "#{Rails.root}/public/200.html", :status => 200
  end
end
