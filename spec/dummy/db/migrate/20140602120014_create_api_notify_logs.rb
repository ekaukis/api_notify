class CreateApiNotifyLogs < ActiveRecord::Migration
  def change
    create_table :api_notify_logs do |t|
      t.references :item, index: true
      t.string :endpoint

      t.timestamps
    end
  end
end
