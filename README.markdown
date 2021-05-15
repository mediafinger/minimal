# README --minimal

A _minimal_ Rails 6.1 app created with Ruby 3.0

To be a reasonable template a few additions have been added:

* RSpec setup
* Rubocop setup (incl. my opinionated _.rubocop.yml_)
* a task `rake ci` that executes `rubocop`, `rspec` and `bundler:audit`
* a Settings class to handle (almost) all ENV variables in a central place
* Postgres setup with extension to use UUIDs
* Ensuring `request_id` is always available for tracing and logging
* Custom error handling middleware to catch all errors, log them and return them in a structured way

> _Check the first (12) commits individually to see what has been added or changed._

[![GitHub Actions CI Build Status](https://github.com/mediafinger/minimal/actions/workflows/ci.yml/badge.svg)](https://github.com/mediafinger/minimal/actions/workflows/ci.yml)

## Dependencies

To test or run the app, you need to have:

* **Ruby version** `3.0.1` installed
* **Postgres version** `>= 10.0`  installed

## Installation

Clone the repo:

`git clone git@github.com:mediafinger/minimal.git`

## Local Setup

Change into the newly create directory `cd minimal` and run:

`bundle install`

Then create the _development_ and _test_ databases:

`bin/rails db:setup`

> _When just pulling changes, run `bin/rails db:migrate` to execute database migrations._

## Run the tests

`bin/rails ci` will execute:

- `rubocop` - to ensure a consistent style
- `rspec` - to run all existing specs
- `bundle:audit` - to check for vulnerabilities in the gems

You can also run and of them on their own:
- `bin/rails rubocop` or `bin/rails rubocop:auto_correct`
- `bundle exec rspec spec/`
- `bundle exec bundler:audit` or `bin/rails bundle-audit`

> _When you push a new commit, the **CI** will run `bin/rails ci`. Please check the latest jobs under:
https://github.com/mediafinger/minimal/actions_  
> As there is no custom business logic yet, the test suite does not contain specs yet.

## Open the console

Like in any Rails application `bin/rails c` will open the console with the app loaded.  
It will also load `amazing_print` to have nicer console output in development.

## Inject configuration into the application

In the file _config/settings.rb_ (default) configs for the development and test (also CI) environments are defined.  
If you want to overwrite some values for your local development, you have two possibilities: 

Either add those lines to a _config/settings.local.rb_ file with the following syntax:

```ruby
Settings.set :some_registered_variable, "my_value"
```

> _This file is listed in **.gitignore** already, so you won't accidentally publish your secrets._

Or you set **ENV**ironment variables on your machine (or in your Docker config files) like you would do on production servers.

```shell
export SOME_REGISTERED_VARIABLE='my_value'
```

When starting the application in _production_ or _staging_ environments on remote server, you will have to ensure that all ENV variables are set, which are marked as `mandatory: true`. If you forget
to set one a `KeyError: key not found: 'VARNAME'` will be raised on boot. (Which is better than 'silent' errors at Runtime.)

## Start the server

`bin/rails s` will make the app available under http://localhost:3000

> _There are no routes or controller actions created yet, so the first request will **timeout**_

## Custom error handling

When you start developing your application based on this template, you will notice the error messages
are rendered to JSON. This is being done in the _lib/errors/middleware_.

With this error middleware, you don't have to rescue any errors in your controllers, when you develop an API.
Just let the middleware catch them and handle them all in a consistent way.
If you need special error handling just add your custom error to the `MAP_KNOWN_ERRORS` hash.

If you do not build an API, but a classical website which renders views, you have to:
- uncomment the `render_error_view` method in the middleware and adapt it to you needs
- add an error view template and use it in the `render_error_view` method
- call the `render_error_view` in `render_generic_error` & `render_custom_error`
- and most likely you also want to rescue some errors in your controller actions to provide a nicer UX

If you prefer Rails verbose error pages in development, you can adapt in the _config/settings.rb_ class
the `display_rails_error_page` default value to e.g. `rails_env == 'development'`
(I recommend to render the errors the same way in the _test_ environment as in the _production_ environments.)

## Copyright

The code is published under the MIT License and you are free to do with it as you please. If you find this
minimal rails app template helpful, I'd be happy about a mention.

I'm also available to hire as a freelancer: https://mediafinger.com/
