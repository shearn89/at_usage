module MachinesHelper
	def sortable(column, title = nil)
		title ||= column.titleize
		css_class = column == sort_column ? "current #{sort_direction}" : nil
		if %w[name lab].include?(column)
			direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
		else
			direction = column == sort_column && sort_direction == "desc" ? "asc" : "desc"
		end
		link_to title, params.merge(:sort => column, :direction => direction), {:class => css_class}
	end
end
