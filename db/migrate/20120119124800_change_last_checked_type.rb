class ChangeLastCheckedType < ActiveRecord::Migration
	def up
		change_column :machines, :last_checked, :datetime
	end
	def down
	  raise ActiveRecord::IrreversibleMigration
	end
end

