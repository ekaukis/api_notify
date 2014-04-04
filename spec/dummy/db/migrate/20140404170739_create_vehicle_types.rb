class CreateVehicleTypes < ActiveRecord::Migration
  def change
    create_table :vehicle_types do |t|
      t.string :title
      t.string :category
      t.references :vehicle, index: true

      t.timestamps
    end
  end
end
