class HomeController < ApplicationController

  require 'active_resource/connection'

class ActiveResource::Connection
  def apply_ssl_options_with_ssl_version(http)
    apply_ssl_options_without_ssl_version(http)

    http.ssl_version = @ssl_options[:ssl_version] if @ssl_options[:ssl_version]

    http
  end

  alias_method_chain :apply_ssl_options, :ssl_version
end

ShopifyAPI::Base.ssl_options = {:ssl_version => :TLSv1}
  
  around_filter :shopify_session, :except => 'welcome'
  
  def welcome
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    @callback_url = "http://#{current_host}/login"
  end
  
  def index

#@w = ShopifyAPI::Webhook.create(:topic => "orders/updated", :address => "http://polar-badlands-9376.herokuapp.com/webhooks/orders/update", :format => "xml")
#@w.save

@webhooklist = ShopifyAPI::Webhook.find(:all, :params => {:limit => 30})


#@webhook = ShopifyAPI::Webhook.find(2422492) 

#@webhook.destroy
       
#w = Webhook.create topic: "orders/create", address: "http://whatever.place.com", format: "json"

    # get 5 products
    @productsnh = ShopifyAPI::Product.find(:all, :params => {:limit => 10})

    # get latest 5 orders
    @orders   = ShopifyAPI::Order.find(:all, :params => {:limit => 10, :order => "created_at DESC" })

@licensekeyorder = ShopifyAPI::Order.find(:all, :params => {:limit => 1}) 

@shopid = ShopifyAPI::Shop.current


require 'openssl'

# in a real rsa implementation, message would be the symmetric key
# used to encrypt the real message data
# which would be 'yourpass' in snippet http://www.bigbold.com/snippets/posts/show/576

secret = @licensekeyorder.billing_address.name + @licensekeyorder.email + @licensekeyorder.created_at

require 'digest/sha1'
require "base64"



base64key = Digest::SHA1.digest("secret")
@secret = secret




message = secret
puts "\nOriginal Message: #{secret}\n"
puts "Using SHA1 Digest\n"

puts "Using ruby-openssl to generate the public and private keys\n"

# .generate creates an object containing both keys
new_key = OpenSSL::PKey::RSA.generate( 1024 )
puts "Does the generated key object have the public key? #{new_key.public?}\n"
puts "Does the generated key object have the private key? #{new_key.private?}\n\n"

# write the new keys as PEM's
new_public = new_key.public_key
puts "New public key pem:\n#{new_public}\n"
puts "The new public key in human readable form:\n"
puts new_public.to_text + "\n"

output_public = File.new("./new_public.pem", "w")
output_public.puts new_public
output_public.close

new_private = new_key.to_pem
puts "new private key pem:\n#{new_private}\n"

output_private = File.new("./new_private.pem", "w")
output_private.puts new_private
output_private.close

puts "\nEncrypt/decrypt using previously saved pem files on disk...\n"
# we encrypt with the public key
# note: of course the public key PEM contains only the public key
puts "Reading Public Key PEM...\n"
public_key = OpenSSL::PKey::RSA.new(File.read("./new_public.pem"))
puts "Does the public pem file have the public key? #{public_key.public?}\n"
puts "Does the public pem file have the private key? #{public_key.private?}\n"
puts "\nEncrypting with public key ...\n"

cipher_text = Base64.encode64(public_key.public_encrypt( message ))
puts "License Key:\n#{cipher_text}\n"

# get the private key from pem file and decrypt
# note the private key PEM contains both keys
puts "\nReading Private Key PEM...\n"
private_key = OpenSSL::PKey::RSA.new(File.read("./new_private.pem"))
puts "Does the private pem file have the public key? #{private_key.public?}\n"
puts "Does the private pem file have the private key? #{private_key.private?}\n"
puts "\nDecrypting with private key ...\n"
clear_text = private_key.private_decrypt(Base64.decode64(cipher_text) )

puts "\nOutput Text:\n#{clear_text}\n\n"

@pubkey = public_key
@privkey = private_key
@cipher = cipher_text
@clrtext = clear_text

@licensekeyorder.note = cipher_text
@licensekeyorder.save


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
    topics = ["products/create", "products/update", "products/delete"]
    
    topics.each do |topic|
      webhook = ShopifyAPI::Webhook.create(:format => "json", :topic => topic, :address => "http://#{DOMAIN_NAMES[RAILS_ENV]}/webhooks/#{topic}")
      raise "Webhook invalid: #{webhook.errors}" unless webhook.valid?
    end
  end



def rsa


# Tasks demonstrated:
#       Creating a public-private key pair
#       Saving individual keys to disk in PEM format
#       Reading individual keys from disk
#       Encyrpting with public key
#       Decrypting with private key
#       Checking whether a key has public | private key

require 'openssl'

# in a real rsa implementation, message would be the symmetric key
# used to encrypt the real message data
# which would be 'yourpass' in snippet http://www.bigbold.com/snippets/posts/show/576

require 'digest/sha1'
require "base64"

secret = 'testname@testdomainmail.com, order date 15/11/2013'

base64key = Digest::SHA1.digest("secret")
@secret = secret


message = secret
puts "\nOriginal Message: #{secret}\n"
puts "Using SHA1 Digest\n"

puts "Using ruby-openssl to generate the public and private keys\n"

# .generate creates an object containing both keys
new_key = OpenSSL::PKey::RSA.generate( 1024 )
puts "Does the generated key object have the public key? #{new_key.public?}\n"
puts "Does the generated key object have the private key? #{new_key.private?}\n\n"

# write the new keys as PEM's
new_public = new_key.public_key
puts "New public key pem:\n#{new_public}\n"
puts "The new public key in human readable form:\n"
puts new_public.to_text + "\n"

output_public = File.new("./new_public.pem", "w")
output_public.puts new_public
output_public.close

new_private = new_key.to_pem
puts "new private key pem:\n#{new_private}\n"

output_private = File.new("./new_private.pem", "w")
output_private.puts new_private
output_private.close

puts "\nEncrypt/decrypt using previously saved pem files on disk...\n"
# we encrypt with the public key
# note: of course the public key PEM contains only the public key
puts "Reading Public Key PEM...\n"
public_key = OpenSSL::PKey::RSA.new(File.read("./new_public.pem"))
puts "Does the public pem file have the public key? #{public_key.public?}\n"
puts "Does the public pem file have the private key? #{public_key.private?}\n"
puts "\nEncrypting with public key ...\n"

cipher_text = Base64.encode64(public_key.public_encrypt( message ))
puts "License Key:\n#{cipher_text}\n"

# get the private key from pem file and decrypt
# note the private key PEM contains both keys
puts "\nReading Private Key PEM...\n"
private_key = OpenSSL::PKey::RSA.new(File.read("./new_private.pem"))
puts "Does the private pem file have the public key? #{private_key.public?}\n"
puts "Does the private pem file have the private key? #{private_key.private?}\n"
puts "\nDecrypting with private key ...\n"
clear_text = private_key.private_decrypt(Base64.decode64(cipher_text) )

puts "\nOutput Text:\n#{clear_text}\n\n"

@pubkey = public_key
@privkey = private_key
@cipher = cipher_text
@clrtext = clear_text



end 


end