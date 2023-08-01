class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.integer :grade
      t.text :text, null: false

      t.bigint :user_id, null: false
      t.bigint :post_id, null: false

      t.timestamps
    end

    add_foreign_key :comments, :users, column: :user_id, primary_key: :id
    add_foreign_key :comments, :posts, column: :post_id, primary_key: :id
  end
end
