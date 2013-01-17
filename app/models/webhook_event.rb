class WebhookEvent < ActiveRecord::Base
  belongs_to :product
  belongs_to :shop
  attr_accessible :event_type
  attr_accessible :description
end
