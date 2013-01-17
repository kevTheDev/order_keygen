class WebhookController < ApplicationController


around_filter :shopify_session, :except => 'welcome'
#before_filter :verify_webhook, :except => 'verify_webhook'
@SHARED_SECRET = '5ff673736415fce868a3c0df89cbfd51'

 def welcome
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    @callback_url = "http://#{current_host}/login"
end


 def index

@products_sync = ShopifyAPI::Product.find(117661124)
 @products_sync.tags = "test-webhook"
@products_sync.save


 end

  def product_new
    data = ActiveSupport::JSON.decode(request.body.read)
puts "Decoded: #{data}"

 #@products_sync = ShopifyAPI::Product.find(data["id"])
 #@products_sync.tags = "test-webhook"
#@products_sync.save

    if Product.where('shopify_id = ?', data["id"]).first.blank?
      event = WebhookEvent.new(:event_type => "product new")
      event.save
      product = Product.new(:name => data["title"], :shopify_id => data["id"])
      product.webhook_events << event
      product.save
    end
      head :ok
  end

  def product_updated
    data = ActiveSupport::JSON.decode(request.body.read)
    puts "data = " + data.to_s
    product = Product.where('shopify_id = ?', data["id"]).first
    if product
      event = WebhookEvent.new(:event_type => "product update")
      event.save
      product.name = data["title"]
      product.webhook_events << event
      product.save
    end
      head :ok
  end



  def order_updated
    string = request.body.read
    data =  Hash.from_xml(string)
    puts "data = " + data.to_s
    event = WebhookEvent.new(:type => "order update")
    event.save
    #product = Product.where('shopify_id = ?', data["id"]).first
    #if product
     # event = WebhookEvent.new(:event_type => "order update")
      #event.save
      #product.name = data["title"]
      #product.webhook_events << event
      #product.save
    # end
      head :ok
  end


  def product_deleted
    data = ActiveSupport::JSON.decode(request.body.read)
    product = Product.where('shopify_id = ?', data["id"]).first
    if product
      puts 'products shop id: ' + product.shop.id
      event = WebhookEvent.new(:event_type => "product delete")
      event.save
      product.logical_delete = true
      product.webhook_events << event
      product.shop.webhook_events << event
      product.shop.save
      product.save
    end
    head :ok
  end
 


end


