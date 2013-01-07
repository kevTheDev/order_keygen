AdminData.config do |config|
    #comment
    config.is_allowed_to_view = lambda {|controller| return true if (Rails.env.development? || Rails.env.production? || Rails.env.staging?) }
end