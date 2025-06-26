class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :status, null: false, default: "offline"
      t.datetime :last_online_at

      t.timestamps
    end
  end
end
