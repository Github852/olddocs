These instructions make the following assumptions:
- You've just finished setting up a Linux server (say, Ubuntu 16.04 64-bit) and have installed Docker on it.
- You've configured your security groups to allow for incoming SSH connections from your local IP.
- You've configured a domain name (or subdomain) to point to your server's IP address.
- You've configured the DNS to enable HTTPS for your domain (say, using Cloudflare).

### Getting started

1. SSH into your new server:

   ``` bash
   $ ssh -l {user} {IP to the server}
   ```

2. Update your system:

   ``` bash
   $ sudo apt-get update
   $ sudo apt-get upgrade
   ```

3. Install Git:

   ``` bash
   $ sudo apt-get update
   $ sudo apt-get install -y git
   ```

4. Make sure you are in your home directory and clone the Standard File [ruby-server](https://github.com/standardfile/ruby-server) project:

   ``` bash
   $ cd ~
   $ git clone https://github.com/standardfile/ruby-server.git
   $ cd ruby-server
   ```

5. Create `.env.{app|db}.production` files in the project's Docker environment directory:

   ``` bash
   $ cd $PROJECT_ROOT/docker/environments/
   $ cp .env.app.production.template .env.app.production
   $ cp .env.db.production.template .env.db.production
   ```

   Ensure that the `.env.app.production` file contains the below environment variables:
   
   ```bash
   $ cat .env.app.production
   RAILS_ENV=production
   SECRET_KEY_BASE=use "bundle exec rake secret"
   RAILS_SERVE_STATIC_FILES=true

   DB_CONNECTION=mysql
   DB_HOST=db
   DB_DATABASE=standardfile
   DB_USERNAME=root
   DB_PASSWORD=
   ```

   Ensure that the `.env.db.production` file contains the below environment variable:

   ``` bash
   $ cat .env.db.production
   MYSQL_ROOT_PASSWORD=
   ```
   
   If you set a password for the root database user under `DB_PASSWORD` in `.env.db.production`, you must set the same password under `MYSQL_ROOT_PASSWORD` in `.env.db.production`.

6. Build the services without starting them:

   ``` bash
   $ docker-compose build
   ```

7. Run the `app` service to compile the assets:

   ``` bash
   $ docker-compose -f docker-compose.yml -f docker-compose.production.yml up -d app
   $ docker-compose exec app bundle exec rake assets:precompile
   ```

   At this point the precompiled assets are stored in the `public/`
   folder of the host. The Nginx container will mount the folder as a volume
   and get the assets.

   ``` bash
   $ docker-compose down
   ```

8. Start the services:

   ``` bash
   $ docker-compose -f docker-compose.yml -f docker-compose.production.yml up -d
   ```

9. Login to the `app` service to initialize the project:

   ``` bash
   $ docker-compose exec app bundle exec rake db:create db:migrate
   ```

10. Access the server locally:

    ``` bash
    $ curl {domain name}
    <!doctype html>
    <html>
      ...
      <body>
        <h1> Hi! You're not supposed to be here. </h1>

        <p> You might be looking for the <a href="https://app.standardnotes.org"> Standard Notes Web App</a> or the main <a href="https://standardnotes.org"> Standard Notes Website</a>. </p>

      </body>
    </html>
    ```

11. You're done!

### Using your new server

You can immediately start using your new server by using the Standard Notes app at https://app.standardnotes.org.

In the account menu, choose `Advanced Options` when signing in to specify your server.

Then, register for a new account, and begin using your private new secure Standard File server!
