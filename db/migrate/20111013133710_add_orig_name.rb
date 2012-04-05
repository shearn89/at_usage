class AddOrigName < ActiveRecord::Migration
	def change
		change_table :machines do |m|
			m.string :orig_name
		end
	end
end
