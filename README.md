Zoho Cliq plugin for Redmine
============================

This plugin posts updates to issues in your Redmine to [Zoho Cliq](https://cliq.zoho.com/) channel.

Features
--------

* Post information to messenger channel
  * post issue updates
  * post private issue updates
  * display watchers
  * convert username to mentions
  * post wiki updates
  * post db entry (if redmine_db is installed) updates
  * post password (if redmine_passwords is installed) updates
  * post contact (if redmine_contacts is installed) updates
* overwrite messenger settings at project level

Requirements
------------

* Redmine version >= 3.0.0
* Ruby version >= 2.3.0


Installation
------------

Install ``redmine_zoho_cliq`` plugin for `Redmine`

    cd $REDMINE_ROOT
    git clone https://github.com/myhope8729/redmine_zoho_cliq.git plugins/redmine_zoho_cliq
    bundle install --without development test
    bundle exec rake redmine:plugins:migrate RAILS_ENV=production

Restart Redmine (application server) and you should see the plugin show up in the Plugins page.
Under the configuration options, set the Zoho Cliq Token and channel.
For project based message function, go to project and messenger tab and set Cliq channel.


Uninstall
---------

Uninstall ``redmine_zoho_cliq``

    cd $REDMINE_ROOT
    bundle exec rake redmine:plugins:migrate NAME=redmine_zoho_cliq VERSION=0 RAILS_ENV=production
    rm -rf plugins/redmine_zoho_cliq

Restart Redmine (application server)