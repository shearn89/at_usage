# Deploying the Application #
1. Navigate to your www directory, e.g. `cd /var/www` for apache default.
2. Clone the git repository for the application: `git clone git://github.com/shearn89/at_usage.git`. You'll obviously need write access to the www folder.
3. `chmod a+r at_usage`
4. Install imagemagick and the development headers, which is required for the sparkline graph generation. This will be distribution-dependent. On ubuntu, the headers package is called "libmagick9-dev" - it may be something similar on other distros.
5. `cd at_usage; bundle install`. This may produce errors, simply follow the instructions they give and all should work fine.
6. Edit the production database details in `config/database.yml`. This is the apps local database, so the details should match those created during step 9 of the server setup.
7. Run `rake db:setup`

Now, we edit files to allow connection to the postgreSQL database.

1. Connection details for the server should be added to the top of `script/postgres_update.rb`.
2. A table should be created on the postgreSQL server, with the following schema. The indices are recommended for speed.

     Column  |            Type             |   Modifiers   
    ---------+-----------------------------+---------------
     host    | character varying(32)       | 
     usage   | integer                     | 
     logtime | timestamp without time zone | default now()
    Indexes:
        "lt" btree (logtime)
        "lt2" btree (date_trunc('min'::text, logtime))

3. Edit the connection details on line 128 of `machines_controller.rb`.

1. Edit the "script/db_script.sh" with the path to the .pgpass file (an example is contained in the doc/ folder). Make sure the .pgpass file is readable by the user that the cron task runs as.

Edit script/db_script.sh:
Relevant scripts that will need editing are the `script/db_script.sh` file, which should be edited with the path to the PostgeSQL .pgpass file which has been placed somewhere globally readable, and should be set up as the cronjob to run at whatever interval you wish to collect data for.



Edit production database data in config/database.yml

Finally run `rake db:setup` on the web server, and restart the web service. DNS setup etc is not covered in this guide.
