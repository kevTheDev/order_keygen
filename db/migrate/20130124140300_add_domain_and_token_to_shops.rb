class AddDomainAndTokenToShops < ActiveRecord::Migration
  def change
    add_column :shops, :domain, :string
    add_column :shops, :token, :text
  end
end
