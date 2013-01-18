class Product < ActiveRecord::Base
  validates_uniqueness_of :shopify_id
  
  has_many :webhook_events
  belongs_to :shop
  attr_accessible :name
  attr_accessible :price
  attr_accessible :shopify_id
  attr_accessible :shop_id
end
