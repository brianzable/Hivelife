Hivelife
======
Hivelife is a record keeping tool for beekeepers.
The project uses Ruby 2.1.1 and Rails 4.1.
You can visit the site at [hivelife.co](https://hivelife.co).

Deployment
--
```
$ cd bees-web
$ bundle install
$ cp config/database.yml.example config/database.yml
$ cp config/secrets.yml.example config/secrets.yml
$ rake db:create db:schema:load
$ rails server
```
Prior to running the application, the secrets.yml file will need to be configured.
A secret_base_key and secret key for Devise need to be generated.
These can be generated using rake:
```
$ rake secret
```

In order for any Google Maps and photo uploading features to work,
keys for Amazon Web Services and Google Maps must be also be added to the
secrets.yml file.

Get Involved
--
If you want to help with development, feel free to fork the project and submit a pull request.

License
--
This code is licensed under the GNU General Public License version 3. The full text of the license is available at: [gnu.org/copyleft/gpl.html](http://www.gnu.org/copyleft/gpl.html)
