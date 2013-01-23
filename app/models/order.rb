class Order < ActiveRecord::Base
  
  validates :shopify_id, presence: true, uniqueness: true
  
  attr_accessible :shopify_id
  
end
