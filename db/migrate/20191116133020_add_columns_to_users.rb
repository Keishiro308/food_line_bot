class AddColumnsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :categories, :string, array: true
  end
end
