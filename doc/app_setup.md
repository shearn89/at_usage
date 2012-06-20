# Deploying the Application #
Download tarball

unzip to your /www folder for the server. This will create an at_usage folder. Make this world readable, and writable by the web user.

Edit script/db_script.sh:
Relevant scripts that will need editing are the `script/db_script.sh` file, which should be edited with the path to the PostgeSQL .pgpass file which has been placed somewhere globally readable, and should be set up as the cronjob to run at whatever interval you wish to collect data for.

Then, connection details for the PostgreSQL server should be added to the top of the `script/postgres_update.rb` file. A table of the following form should be created on the Postgres server (the indices are recommended).

 Column  |            Type             |   Modifiers   
---------+-----------------------------+---------------
 host    | character varying(32)       | 
 usage   | integer                     | 
 logtime | timestamp without time zone | default now()
Indexes:
    "lt" btree (logtime)
    "lt2" btree (date_trunc('min'::text, logtime))


 and also to line 128 in `machines_controller.rb`. This will allow the system to connect to the server to estimate usage.

Edit production database data in config/database.yml

Finally run `rake db:setup` on the web server, and restart the web service. DNS setup etc is not covered in this guide.
