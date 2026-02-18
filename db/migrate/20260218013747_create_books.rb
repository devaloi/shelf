class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :author, null: false
      t.string :isbn
      t.integer :status, null: false, default: 0
      t.integer :rating
      t.text :notes
      t.string :url

      t.timestamps
    end
    add_index :books, :status
    add_index :books, %i[user_id status]
  end
end
