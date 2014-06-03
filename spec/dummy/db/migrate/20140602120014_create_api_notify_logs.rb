class CreateApiNotifyLogs < ActiveRecord::Migration
  def change
    create_table :api_notify_logs do |t|
      t.references :api_notify_logable, polymorphic: true
      t.string :endpoint

      t.timestamps
    end
  end
end
