class Order < ActiveRecord::Base
  
  validates :shopify_id, presence: true, uniqueness: true
  
  attr_accessible :shopify_id
  
  def self.for_shopify_id(shopify_id)
    where(shopify_id: shopify_id)
  end
  
end
