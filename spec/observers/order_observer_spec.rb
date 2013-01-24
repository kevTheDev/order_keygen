require 'spec_helper'

describe OrderObserver do
  
  describe 'after_create' do
    
    before do
      @new_order = build(:order)
      @new_order.stub(:generate_licence_key)
    end
    
    it 'should notify the admins' do
      ActiveRecord::Observer.with_observers(:order_observer) do
        @new_order.should_receive(:generate_licence_key).once
        @new_order.save
      end
    end
    
  end
  # after_create
  
end