class HookController < ApplicationController
  
  around_filter :shopify_session, :except => 'welcome'
 
  def welcome
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    @callback_url = "http://#{current_host}/login"
  end

  
  def index
    if Shop.where(:name => ShopifyAPI::Shop.current.name).exists?
      session[:shop] = Shop.where(:name => ShopifyAPI::Shop.current.name).first
      shopid = session[:shop].name 
      get_products shop
    else    
      shop = Shop.new(:name => ShopifyAPI::Shop.current.name, :url => "http://#{ShopifyAPI::Shop.current.domain}", :installed => true)
      shop.save
      session[:shop] = shop
      shopid = "test"
     #init_webhooks
     get_products shop
    end
    
    puts  "Name of Shop: #{shopid}"
    @webhook_events = WebhookEvent.limit(30).order('id ASC')
    @products = Product.where(:logical_delete => nil, :shop_id => session[:shop].id)

  end
  
  private
  
  def get_products(shop)
    limit = 250
    all_products = Array.new
    products = ShopifyAPI::Product.find(:all, :params => {:limit => limit})
    all_products = all_products.concat products
    puts products.length
    while products.length == limit do
      since_id = products.last.id
      products = ShopifyAPI::Product.find(:all, :params => {:limit => limit, :since_id => since_id})
      all_products = all_products.concat products
    end
    
    all_products.each do |product|
      unless Product.where('shopify_id = ?', product.id).exists?
        Product.new(:name => product.title, :shopify_id => product.id, :shop => shop).save
      end
    end
  end
  
  def init_webhooks
    topics = ["products/create", "products/update", "products/delete", "orders/create", "orders/updated"]
   # webhook = ShopifyAPI::Webhook.create(format: "json", topic: "products/create", address: "http://polar-badlands-9376.herokuapp.com/webhooks/products/create")
    topics.each do |topic|
      webhook = ShopifyAPI::Webhook.create(:format => "xml", :topic => topic, :address => "http://polar-badlands-9376.herokuapp.com/webhooks/#{topic}")
     raise "Webhook invalid: #{webhook.errors}" unless webhook.valid?
    end
  end
  
end