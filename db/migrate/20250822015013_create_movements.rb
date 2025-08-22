class CreateMovements < ActiveRecord::Migration[8.0]
  def change
    create_table :movements, id: :uuid do |t|
      t.string :title
      t.text :description
      t.float :amount
      t.integer :movement_type
      t.string :category
      t.datetime :date
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
