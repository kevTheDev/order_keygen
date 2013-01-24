require 'spec_helper'

describe WebhookController do
  
  
  describe 'POST order_paid' do
    
    before do
      WebhookController.any_instance.stub(:verify_webhook) { true }
      @shopify_id = '237'
      
      ActiveSupport::JSON.stub(:decode) { { 'id' => @shopify_id } }
    end
    
    context 'existing Order record' do
      
      before do
        create(:order, shopify_id: @shopify_id)
      end
      
      it 'should not create a new Order' do
        lambda {
          post :order_paid
        }.should_not change(Order, :count)
      end
      
    end
    # existing Order record
    
    context 'no Order record found' do
      
      it 'should create a new Order' do
        lambda {
          post :order_paid
        }.should change(Order, :count).by(1)
      end
      
    end
    # no Order record found
    
  end
  # POST order_paid
  
end