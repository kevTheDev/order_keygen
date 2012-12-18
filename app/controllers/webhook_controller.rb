class WebHookController < ApplicationController

    def product_new
      data = ActiveSupport::JSON.decode(request.body.read)
      shopify_id = data["id"]

      Product.new_from_shopify(@s, shopify_id)

      head :ok
    end

 
end


