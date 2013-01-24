require 'base64'


class WebhookController < ApplicationController

  before_filter :verify_webhook, :except =>[:index]

  def welcome
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    @callback_url = "http://#{current_host}/login"
  end


  def index
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


  def order_paid
    data = ActiveSupport::JSON.decode(request.body.read)

    if Order.for_shopify_id(data['id']).empty?
      order = Order.new(shopify_id: data['id'])
      order.save
    end
    
    head :ok
  end

  private
  
  def verify_webhook
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


