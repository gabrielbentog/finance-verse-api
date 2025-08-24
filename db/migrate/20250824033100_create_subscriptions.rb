class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.string :name
      t.integer :category
      t.float :amount
      t.boolean :is_variable_amount
      t.string :payment_method
      t.integer :frequency
      t.integer :billing_day
      t.integer :status
      t.date :started_at
      t.date :ended_at
      t.float :total_spent
      t.string :last_used
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
