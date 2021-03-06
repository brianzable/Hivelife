Hivelife
======
Hivelife is a record keeping tool for beekeepers.
The project uses Ruby 2.1.1 and Rails 4.1.
You can visit the site at [hivelife.co](https://hivelife.co).

Deployment
--
```
$ cd Hivelife
$ bundle install
$ cp config/database.yml.example config/database.yml
$ cp config/secrets.yml.example config/secrets.yml
$ rake db:create db:schema:load
$ rails server
$ cd client
$ npm install
$ bower install
$ gulp serve
```
Prior to running the application, the secrets.yml file will need to be configured.
A secret_base_key and secret key for Devise need to be generated.
These can be generated using rake:
```
$ rake secret
```

Development Status
--
Hivelife is almost ready for primetime. Some deploy scripts need to be added and some minor design changes need to be implemented
before it is deployed for the world to use.

Get Involved
--
If you want to help with development, feel free to fork the project and submit a pull request.

License
--
This code is licensed under the GNU General Public License version 3. The full text of the license is available at: [gnu.org/copyleft/gpl.html](http://www.gnu.org/copyleft/gpl.html)
