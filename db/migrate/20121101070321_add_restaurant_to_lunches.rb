class AddRestaurantToLunches < ActiveRecord::Migration
  def change
    add_column :lunches, :restaurant, :string
    add_column :lunches, :link, :string
  end
end
