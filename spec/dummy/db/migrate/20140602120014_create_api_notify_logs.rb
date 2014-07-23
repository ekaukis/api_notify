class CreateApiNotifyLogs < ActiveRecord::Migration
  def change
    create_table :api_notify_logs do |t|
      t.references :api_notify_logable, polymorphic: true
      t.string :endpoint

      t.timestamps
    end

    add_index :api_notify_logs, [:api_notify_logable_id, :api_notify_logable_type], name: :api_notify_logs_unique_index_on_api_notify_logable
  end
end
