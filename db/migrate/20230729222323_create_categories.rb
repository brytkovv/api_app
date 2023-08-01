class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories, id: false do |t|
      t.string :key, null: false, primary_key: true
      t.string :name, null: false
      t.text :description, null: false

      t.timestamps
    end
  end
end