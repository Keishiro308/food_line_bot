class RemoveLineIdFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users,:line_id
    add_column :users, :line_id, :string, null: false
  end
end
