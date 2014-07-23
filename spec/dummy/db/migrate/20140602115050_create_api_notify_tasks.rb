class CreateApiNotifyTasks < ActiveRecord::Migration
  def change
    create_table :api_notify_tasks do |t|
      t.text :fields_updated
      t.text :identificators
      t.references :api_notifiable, polymorphic: true
      t.string :endpoint
      t.string :method
      t.text :response
      t.integer :depending_id
      t.boolean :done, default: false
      t.string :changes_hash, index: true, limit: 32

      t.timestamps
    end

    add_index :api_notify_tasks, [:api_notifiable_id, :api_notifiable_type], name: :api_notify_tasks_unique_index_on_api_notifiable
  end
end
