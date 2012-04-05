class AddLastCheckedToMachines < ActiveRecord::Migration
  def change
  	change_table :machines do |m|
		m.string :last_checked
	end
  end
end
