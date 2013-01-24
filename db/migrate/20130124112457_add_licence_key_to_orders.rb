class AddLicenceKeyToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :licence_key, :text
  end
end
