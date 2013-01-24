require 'digest/sha1'
require "base64"

#require 'shopify_api'

class Order < ActiveRecord::Base
  
  validates :shopify_id, presence: true, uniqueness: true
  
  attr_accessible :shopify_id
  
  def self.for_shopify_id(shopify_id)
    where(shopify_id: shopify_id)
  end
  
  def generate_licence_key
    shopify_order = ShopifyAPI::Order.find(self.shopify_id)
    cipher_text   = Order.generate_cipher_for_shopify_order(shopify_order)
    
    self.licence_key = cipher_text
    self.save
    
    shopify_order.note = cipher_text
    shopify_order.save
  end
  
  def self.generate_cipher_for_shopify_order(shopify_order)
    secret = shopify_order.billing_address.name + shopify_order.email + shopify_order.created_at

    # .generate creates an object containing both keys
    keys        = OpenSSL::PKey::RSA.generate( 1024 )
    public_key  = keys.public_key
    private_key = keys.to_pem

    public_key  = OpenSSL::PKey::RSA.new(public_key)
    private_key = OpenSSL::PKey::RSA.new(private_key)

    cipher_text = Base64.encode64(public_key.public_encrypt( secret ))
    clear_text  = private_key.private_decrypt(Base64.decode64(cipher_text) )

    puts "License Key:\n#{cipher_text}\n"
    
    puts "Clear text:\n#{cipher_text}\n"
    
    cipher_text
  end
  
  
end
