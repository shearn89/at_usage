# Deploying the Application #
## App Configuration ##
1. Navigate to your www directory, e.g. `cd /var/www` for apache default.
2. Clone the git repository for the application: `git clone git://github.com/shearn89/at_usage.git`. You'll obviously need write access to the www folder.
3. `chmod a+r at_usage`
4. Install imagemagick and the development headers, which is required for the sparkline graph generation. This will be distribution-dependent. On ubuntu, the headers package is called "libmagick9-dev" - it may be something similar on other distros.
5. `cd at_usage; bundle install`. This may produce errors, simply follow the instructions they give and all should work fine.
6. Edit the production database details in `config/database.yml`. This is the apps local database, so the details should match those created during step 9 of the server setup.
7. Set the environment varialbe to 'production': `export RAILS_ENV=production`
7. Run `rake db:setup`
8. Run `rake assets:precompile`
Now is a good time to check things are working: navigate to the webpage in a web browser (either by IP address, or by adding a line to your /etc/hosts file to resolve the name specified in the virtual host file). You should get a custom error 500 page, with the app's styling and navbar across the top.

## PostgreSQL Configuration ##
Now, we edit files to allow connection to the postgreSQL database.

1. Connection details for the server should be added to the top of `script/postgres_update.rb`.
2. A table should be created on the postgreSQL server, with the following schema. The indices are recommended for speed.
```
     Column  |            Type             |   Modifiers   
    ---------+-----------------------------+---------------
     host    | character varying(32)       | 
     usage   | integer                     | 
     logtime | timestamp without time zone | default now()
    Indexes:
        "lt" btree (logtime)
        "lt2" btree (date_trunc('min'::text, logtime))
```        
    **tl;dr**: `create table usage ( host varchar(32), usage integer, logtime timestamp default now() );`

3. Edit the connection details on line 128 of `machines_controller.rb`.
4. Edit the "script/db_script.sh" with the path to the .pgpass file (an example is contained in the doc/ folder). Make sure the .pgpass file is readable by the user that the cron task runs as. Also make sure to edit the PGSQLHOSTNAME bit, so the command actually connects.

The postgreSQL needs a custom function, defined below:

    CREATE OR REPLACE FUNCTION round_time(TIMESTAMP WITH TIME ZONE) 
    RETURNS TIMESTAMP WITH TIME ZONE AS $$ 
    SELECT date_trunc('hour', $1) + INTERVAL '15 min' * ROUND(date_part('minute', $1) / 15.0)  - INTERVAL '5 min'
    $$ LANGUAGE SQL;

This function is essential.

## Final Checks ##

We should now check that the database connections are all okay: you should be in the main app directory, and so able to run `rails runner -e production script/postgres_update.rb`. If that succeeds, run `whenever -w` to create the server cronjob that pulls data from the postgreSQL database.

If it doesn't succeed, troubleshoot it! It will probably be to do with the postgreSQL connection.

If it complains about "NaN", then the database is probably empty. You can manually add a row to the postgreSQL database, then run the `postgre_update.rb` script again to pull it into the app. This should then make the main page display the basic information. Once you've applied the cron task to all the client machines, all should be well.

That's it! Simply generate the cron tasks for the client machines, and all is set...

## Notes ##
There are some email settings that can be changed in `app/mailers/notifier.rb` (which specifies the address to send feedback to), and in `config/environment.rb`, which specifies the user to send the emails from. These can be changed or simply ignored: the current settings are a spare account I created for the original project.
