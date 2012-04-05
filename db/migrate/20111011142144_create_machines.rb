class CreateMachines < ActiveRecord::Migration
  def change
    create_table :machines do |t|
      t.string :name
      t.string :lab
      t.boolean :available
      t.boolean :offline

      t.timestamps
    end
  end
end
