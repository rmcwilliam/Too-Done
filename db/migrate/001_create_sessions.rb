class CreateSessions < ActiveRecord::Migration
  def up
    create_table :sessions do |t|
      t.integer :user_id, null: false # cannot be blank
      t.timestamps null: false 
    end
  end

  def down
    drop_table :sessions
  end
end
