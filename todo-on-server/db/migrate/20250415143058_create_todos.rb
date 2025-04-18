class CreateTodos < ActiveRecord::Migration[8.0]
  def change
    create_table :todos do |t|
      t.string :title
      t.text :content
      t.boolean :status
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
