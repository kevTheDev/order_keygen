class WebhookController < ApplicationController

require 'base64'
require 'openssl'

around_filter :shopify_session, :except => 'verify_webhook'
before_filter :verify_webhook, :except => 'verify_webhook'


 def welcome
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    @callback_url = "http://#{current_host}/login"
end


 def index

@products_sync = ShopifyAPI::Product.find(116966462)
 @products_sync.tags = "test-webhook"
@products_sync.save


 end

  def product_new
    data = ActiveSupport::JSON.decode(request.body.read)
puts "Decoded: #{data}"

    if Product.where('shopify_id = ?', data["id"]).first.blank?
      event = WebhookEvent.new(:event_type => "product new")
      event.save
      product = Product.new(:name => data["title"], :shopify_id => data["id"])
      product.webhook_events << event
      product.save

       @products_sync = ShopifyAPI::Product.find(data["id"])
 @products_sync.tags = "test-webhook"
@products_sync.save
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


 def order_new
    string = request.body.read
    puts "string = " + string
    data =  Hash.from_xml(string)
    puts "data = " + data.to_s
    event = WebhookEvent.new(:event_type => "order new")
     event.save
  
   @order_sync = ShopifyAPI::Order.find(data["id"])
 @order_sync.note = "test-webhook"
@order_sync.save


      head :ok
  end



  def order_updated
    string = request.body.read
    puts "string = " + string
    data =  Hash.from_xml(string)
    puts "data = " + data.to_s
    event = WebhookEvent.new(:event_type => "order update")
     event.save
   # product = Product.where('shopify_id = ?', data["id"]).first
   # if product
     # event = WebhookEvent.new(:event_type => "order update")
      #event.save
      #product.name = data["title"]
      #product.webhook_events << event
      #product.save
   # end
      head :ok
  end

  def order_paid
    string = request.body.read
    puts "string = " + string
    data =  Hash.from_xml(string)
    puts "data = " + data.to_s
    event = WebhookEvent.new(:event_type => "order paid")
     event.save
   # product = Product.where('shopify_id = ?', data["id"]).first
   # if product
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
  
  private
  
  def verify_webhook
    puts "Hello test"
    data = request.body.read.to_s
    puts "Decoded from verify: #{data} \n" 
    hmac_header = request.headers['HTTP_X_SHOPIFY_HMAC_SHA256']
      puts "Header: #{hmac_header} \n"
    digest  = OpenSSL::Digest::Digest.new('sha256')
@SHARED_SECRET = '5ff673736415fce868a3c0df89cbfd51'
    puts "Digest: #{digest} \n"
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, @SHARED_SECRET, data)).strip
      puts "Calc Header: #{calculated_hmac} \n"
    unless calculated_hmac == hmac_header
      head :unauthorized
    end
    request.body.rewind
  end

end


