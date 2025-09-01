class CreateFinancialMovements < ActiveRecord::Migration[8.0]
  def change
    create_table :financial_movements, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.float :amount
      t.integer :movement_type
      t.string :category
      t.text :description
      t.date :date

      t.timestamps
    end
  end
end
