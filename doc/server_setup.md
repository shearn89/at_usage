# Configuring the Server #
The server requires some form of web service to be installed (ie, Apache or nginx), and some form of local database like MySQL to be installed.

**NOTE:** RVM needs to be installed **via sudo**, not directly as root.

1. Prepare installation of RVM:
    1. install build tools such as build-essential
    2. install git
2. Follow the instructions found here: https://rvm.beginrescueend.com/rvm/install for **multi-user install**. (basically, `curl -L https://get.rvm.io | sudo bash -s stable`, and follow output)
3. Check the requirements and install dependencies: `rvm requirements` **NB:** If `rvm` doesn't work after a logout, then add `source /etc/profile.d/rvm.sh` to the bottom of `/etc/bash.bashrc`.
4. `rvmsudo rvm install 1.9.2` followed by `rvmsudo rvm use --default 1.9.2`. These should make sure that all users are now using ruby 1.9.2. Check this by logging out and in again, then typing `rvm list`. If it complains that the default isn't set, run `rvmsudo rvm alias create default 1.9.2`.
5. `rvmsudo gem install bundler`
6. `rvmsudo gem install rails -v 3`
7. Install node.js (or some other javascript executable, see https://github.com/sstephenson/execjs for a list of supported runtimes). Node.js has excellent source-building instructions available at http://apptob.org.
7. Install the passenger module:
    1. `rvmsudo gem install passenger`
    2. `sudo -s; passenger-install-apache2-module` (or `-nginx-module` if nginx is the web server). May be required to install missing software.
8. Configure Apache/Nginx. Add a virtual host entry (example for apache):

    ```
    <VirtualHost *:80>
        ServerName at_usage_server
        DocumentRoot /path/to/www/at_usage/public
        RailsEnv production
        <Directory /path/to/www/at_usage/public>
            Order allow,deny
            Allow from all
            Options -MultiViews
        </Directory>
    </VirtualHost>
    ```
    
    Example for nginx:
    
    ```
    server {        
         listen 80;
         server_name project.shearn89.com;
         root /path/to/www/at_usage/public;
         passenger_enabled on;
    }
    ```
    
    Make sure this host is marked as enabled.

9. Create a database, and grant all privileges on it to a new user with a password. This username/password will be added to the app to connect and store it's local database.
10. Restart any required services.

The server is now ready for the app to be deployed.