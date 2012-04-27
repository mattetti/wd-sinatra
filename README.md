# Weasel Diesel Sinatra

Weasel-Diesel Sinatra app gem, allowing you to generate/update sinatra apps using the Weasel Diesel DSL


## Installation

    $ gem install 'wd_sinatra'

## Usage

### App generation

Once the gem is installed, you can use the generator to create a new
app. Go to the location where you want to generate a new app and type
the following command (replace `<app_name>` by the name you want to
application to have):

    $ wd_sinatra <app_name>

Check the newly generated app

    $ cd <app_name>

You'll need bundler to install the dependencies:

    $ gem install bundler
    $ bundle install

### Starting the server

The app is now ready to use, to start it you can use rack:

    $ bundle exec rackup

This will start the server on port 9292 and the default GET `/hello_world` service will be available at: `http://localhost:9292/hello_world'.

Note that the code won't be reloading automatically in the server when
you make a modification to the source code. For that, you might want to
use Puma + [Guard](https://github.com/jc00ke/guard-puma) or another tool that allows you to do that.
While it's a nice feature to have, a lot of developers like to do that
differently and it seems more sensitive to let them pick the way they
like the most.

### Console

    $ bundle exec bin/console

The console mode is like the server mode but without the server only
concerns such as the sinatra routes config and Rack middleware.

### Documentation generation

    $ rake doc:services

To generate documentation for the APIs you created in the api folder.

### Testing

TODO

## Writing a service

TODO

## Config and hooks

TODO

## Using an ORM

TODO

## Update

To update your app, just update your gem dependency on `wd_sinatra`, you
can also compare the difference between your app and a freshly generated
app by trying to generate a new app named the same as your old app.
The generator will detect conflicts and let you pick an action (diff,
overwrite, ignore...)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
