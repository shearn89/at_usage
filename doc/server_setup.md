# Configuring the Server #
The server requires some form of web service to be installed (ie, Apache or nginx), and some form of local database like MySQL to be installed.

**NOTE:** RVM needs to be installed **via sudo**, not directly as root.

1. Prepare installation of RVM:
    1. install build tools such as build-essential
    2. install git
2. Follow the instructions found here: https://rvm.beginrescueend.com/rvm/install for **multi-user install**. Although this installs it for all users locally, we need to add the lines specified in step 2 to the **top** of `/etc/bash.bashrc`, ensuring that rvm and all $PATHs work over ssh.
3. `rvmsudo rvm install 1.9.2` followed by `rvmsudo rvm use --default 1.9.2`. These should make sure that all users are now using ruby 1.9.2 - easily checkable by logging in as a non-root user and doing `which ruby` (which should include rvm in the path somewhere), or `ruby -v`.
4. `sudo gem install rails`. This should install rails 3.
5. Install node.js (or some other javascript executable, see https://github.com/sstephenson/execjs for a list of supported runtimes). Node.js has handy source-building instructions available at http://apptob.org.
6. Install the passenger module:
    1. `sudo gem install passenger`
    2. `sudo passenger-install-apache2-module` (or `-nginx-module` if nginx is the web server). May be required to install missing software.
    3. Install any dependencies listed for ''Ruby''.
7. Configure Apache/Nginx. Add a virtual host entry (example for apache):

    ```
    <VirtualHost *:80>
        ServerName at_usage_server
        DocumentRoot /path/to/www/at_usage/public
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

8. Create a database, and grant all privileges on it to a new user with a password.

The server is now ready for the app to be deployed.