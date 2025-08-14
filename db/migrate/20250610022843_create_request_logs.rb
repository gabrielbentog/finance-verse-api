class CreateRequestLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :request_logs do |t|
      t.string :method
      t.string :path
      t.string :controller
      t.string :action
      t.integer :status
      t.integer :duration_ms
      t.json :params
      t.string :ip
      t.uuid :user_id
      t.string :model_touched

      t.timestamps
    end
  end
end
