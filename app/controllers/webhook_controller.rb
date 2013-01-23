require 'base64'


class WebhookController < ApplicationController


#skip_around_filter :shopify_session
#around_filter :shopify_session
  before_filter :verify_webhook, :except =>[:verify_webhook, :index]


  def welcome
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    @callback_url = "http://#{current_host}/login"
  end


 def index

#@products_sync = ShopifyAPI::Product.find(116966462)
# @products_sync.tags = "test-webhook"
#@products_sync.save

#session[:shop] = Shop.where(:name => ShopifyAPI::Shop.current.name).first
      
 #     shopid = session[:shop].name 
#puts  "Name of Shop: #{shopid}"

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

       if Shop.where(:name => ShopifyAPI::Shop.current.name).exists?
      session[:shop] = Shop.where(:name => ShopifyAPI::Shop.current.name).first
      shopid = session[:shop].name 
       else
        shopid = "test"

    end

    puts  "Name of Shop: #{shopid}"
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


