# A.T. Usage #

This is the open-sourced repo for my undergraduate fourth year project, which analyzed machine usage in Appleton Tower. The system can bee seen in action at [http://project.shearn89.com], which demos how the system works.

The system requires a `cron` script to be installed on all machines that need to report to it, and the script requires configuring to add records to a PostgreSQL server which holds all the data. 

Relevant scripts that will need editing are the `script/db_script.sh` file, which should be edited with the path to the PostgeSQL .pgpass file, and should be set up as the cronjob to run at whatever interval you wish to collect data for.

Then, connection details for the PostgreSQL server should be added to the top of the `script/postgres_update.rb` file, and also to line 128 in `machines_controller.rb`. This will allow the system to connect to the server to estimate usage.

Finally, create the tables on the PostgreSQL server, and do `rake db:setup` on the web server. The `db_script.sh` may be altered depending on what information you wish to collect from the clients: if you change it, update your PostgreSQL tables as necessary, and you'll have to do some hacking of this system in order to display and process all the data correctly.