class Product < ActiveRecord::Base
  attr_accessible :name, :price

  def self.new_from_shopify(shop, shopify_id)

      shopify_p = ShopifyAPI::Product.find(shopify_id)

      # creates the local product
      local_p = Product.new
      local_p.shopify_id = shopify_p.id
      local_p.name = shopify_p.title
      local_p.shop = shop
      local_p.save

  end
  
end
