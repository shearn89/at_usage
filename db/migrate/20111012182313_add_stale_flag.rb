class AddStaleFlag < ActiveRecord::Migration
    def change
	change_table :machines do |m|
		m.boolean :stale, :default => false
	end
    end
end
