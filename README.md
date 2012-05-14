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
see 'wd_sinatra/test_helpers'

## Writing a service

TODO see Weasel Diesel for now and the generated service example.

## Config and hooks

### app.rb

The `config/app.rb` file is being required after the environment is set
but before the models are loaded. This is the perfect place to load
custom libraries and set your datastore.

This is where you will for instance load ActiveRecord and set your DB
connection.

### Environments

The files in `config/environments` can
be used to set environment specific configuration or other.
If you add a new environment such as staging, you can add a `staging.rb`
file in the environments folder that will only get required when running
in this env mode.
Whatever the environment is, the `config/environments/default.rb` is
being required before the specific env file.

### Hooks

The request dispatcher offers a fews hooks which you can see demonstrated in
`config/hooks.rb`.

* `params_preprocessor_hook(params)`
* `params_postprocessor_hook(params)`
* `params_exception_handler(exception)`
* `pre_dispatch_hook`

The two first hooks are used to process the params and when implemented
are expected to return the params that will be used in the request.

The `params_exception_handler` hook allows you to overwrite the default
exception handling happening when an exception is raised while handling
the params (pre procssing, validation or post processing).

The `pre_dispatch_hook` is called just before the request is dispatched
to the service implementation. This is where you might want to implement
an authentication verification system for instance.

These hooks have access to the entire request context, including the
`service` being called. You can use the service `extra` option to set
some custom settings that can then be used in this pre dispatch hook.

In the default generated application, a body parser is provided to parse
JSON requests when the HTTP verb is PUT, POST or DELETE. The json parser is set by default to use the `JSON` module but you might want to change it to use Yajl for instance.
To do that, edit the `config/hooks.rb` file and change the following:

```ruby
BodyParser.json_parser = JSON
```

to:

```ruby
BodyParser.json_parser = Yajl::Parser
```

Of course, you'll need to require `Yajl` first and add it to your
Gemfile if you want to use Bundler.



## Using an ORM

TODO: see https://github.com/mattetti/sinatra-web-api-example/  for now
for an example of setting up ActiveRecord.
Eventually the generator will take an option to generate an AR, DM or
other ORM template.

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
