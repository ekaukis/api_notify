class CreateApiNotifyTasks < ActiveRecord::Migration
  def change
    create_table :api_notify_tasks do |t|
      t.text :fields_updated
      t.references :notifiable, polymorphic: true
      t.text :synchronized_to
      t.boolean :synchronized

      t.timestamps
    end
  end
end
