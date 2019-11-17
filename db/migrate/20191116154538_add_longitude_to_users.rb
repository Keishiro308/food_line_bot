class AddLongitudeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :long, :float
    add_column :users, :lat, :float
  end
end
