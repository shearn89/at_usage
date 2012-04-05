set :output, {:standard => nil}
every '11/15 * * * *' do
	runner "script/postgres_update.rb"
end