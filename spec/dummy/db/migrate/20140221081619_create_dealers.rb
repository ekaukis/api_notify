class CreateDealers < ActiveRecord::Migration
  def change
    create_table :dealers do |t|
      t.string :title
      t.boolean :synchronized
      t.integer :other_system_id

      t.timestamps
    end
  end
end
