class ToDoLists < ActiveRecord::Migration 

  def up
    create_table :to_do_lists do |t|
      t.string :name, null: false
      t.integer :user_id, null: false
    end
  end

  def down 
    drop_table :to_do_lists
  end
end
