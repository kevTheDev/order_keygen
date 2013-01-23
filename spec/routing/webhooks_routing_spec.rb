require 'spec_helper'

describe WebhookController do
  
  describe 'routing' do
    
    it { get( '/webhooks/index' ).should route_to(  'webhook#index' ) }
    it { get( '/webhooks/index' ).should route_to(  'webhook#index' ) }
    
    it { post( '/webhooks/orders/paid' ).should route_to(  'webhook#order_paid' ) }
    it { post( '/webhooks/orders/create' ).should route_to(  'webhook#order_new' ) }
    
  end
  # routing
  
end