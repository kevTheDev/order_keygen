class OrderObserver < ActiveRecord::Observer
  
  def after_create(order)
    order.generate_licence_key
  end
  
end