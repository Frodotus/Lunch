class CreateLunches < ActiveRecord::Migration
  def change
    create_table :lunches do |t|
      t.string :name
      t.decimal :price, :precision => 5, :scale => 2

      t.timestamps
    end
  end
end
