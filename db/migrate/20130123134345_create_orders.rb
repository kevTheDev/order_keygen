class CreateOrders < ActiveRecord::Migration
  def up
    create_table :orders do |t|
      t.string :shopify_id, null: false, unique: true
      t.timestamps
    end
  end

  def down
    drop_table :orders
  end
end
