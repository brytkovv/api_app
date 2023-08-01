class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.text :title, null: false
      t.text :text, null: false
      t.string :category_id, null: false
      t.bigint :user_id
      t.bigint :comments_count, default: 0, null: false
      # t.attachment :picture

      t.timestamps
    end

    add_foreign_key :posts, :users, column: :user_id, primary_key: :id
    add_foreign_key :posts, :categories, column: :category_id, primary_key: :key
  end
end
