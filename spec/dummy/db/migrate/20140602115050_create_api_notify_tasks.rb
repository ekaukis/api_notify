class CreateApiNotifyTasks < ActiveRecord::Migration
  def change
    create_table :api_notify_tasks do |t|
      t.text :fields_updated
      t.references :api_notifiable, polymorphic: true
      t.string :endpoint
      t.string :method
      t.text :response
      t.boolean :done, default: false

      t.timestamps
    end
  end
end
