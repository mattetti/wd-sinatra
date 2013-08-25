# Weasel Diesel Sinatra

[![Build Status](https://secure.travis-ci.org/mattetti/wd-sinatra.png?branch=master)](https://next.travis-ci.org/mattetti/wd-sinatra)

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
you make a modification to the source code. For that, we include
[rerun](https://github.com/alexch/rerun), which is only enabled in the
development and test environments. Use it like this:

    $ bundle exec rerun -- rackup

### Generating a new service

You need to have thor and active support installed for that, you might want to add it to
your gemfile.

    $ thor :service get /foo/bar foo_bar.rb

This command will create a service and a failing test for it.

### Console

    $ bundle exec bin/console

The console mode is like the server mode but without the server only
concerns such as the sinatra routes config and Rack middleware.

If your users also want `script/console`, add the file, chmod +x it and
use the following code:

```bash
#!/bin/bash
# Run bin/console for those who like the old Rails way.
abspath=$(cd ${0%/*} && echo $PWD/${0##*/})
$abspath/../../bin/console
```

### ORM

By default the generated app doesn't come with any ORMs, but if you want to use ActiveRecord, you can use these gems:

* [wd_sinatra_active_record](https://github.com/mattetti/wd_sinatra_active_record)
* [wd_sinatra_sequel](https://github.com/kamui/wd_sinatra_sequel)


### Documentation generation

    $ rake doc:services

To generate documentation for the APIs you created in the api folder.

### Testing

Helpers to test your apps are provided. When you generate your first
app, you will see a first example using minitest:

```ruby
class HelloWorldIntegrationTest < MiniTest::Unit::TestCase

  def test_default_response
    TestApi.get "/hello_world"
    assert_api_response
    assert_equal "Hello World", TestApi.json_response['message']
    assert Time.parse(TestApi.json_response['at']) < Time.now
  end

  def test_customized_response
    TestApi.get "/hello_world", :name => "Matt"
    assert_api_response
    assert_equal "Hello Matt", TestApi.json_response['message']
    assert Time.parse(TestApi.json_response['at']) < Time.now
  end

end
```

The `TestApi` module is used to call a service. The call will go through
the entire app stack including middleware.
You can then look at the response object via the `TestApi` module using
one of the many provided methods such as `last_response`,
`json_response` and then methods on `last_response` provided by [Rack](http://rack.rubyforge.org/doc/Rack/MockResponse.html):

* status
* headers
* body
* errors

The `TestApi` interface allows you to dispatch all the calls, and to
send custom parameters and headers, set cookies and everything you need to do proper integration
tests.

Because we opted to describe our responses, and this framework is based
on the concept that we want to communicate about our apis, it is
critical to test the service responses. For that, a JSON response helper
is provided (testunit/minitest only for now) so you can easily check
that the structure of the response matches the description.

This is what the `assert_api_response` helper does.

This helper is to be used after you dispatched an API call.
The last response is being analyzed and the JSON structure should match
the description provided in the service.
Note that this helper doesn't check the content of the structure, that
is something you need to do yourself with custom tests as shown in the
example.

### Tips

When dispatching a test api call using an url with a placeholder such as
`/people/:id', you need to pass the id as a param and the url will be
properly composed:

```ruby
TestApi.post '/people/:id', :id => 123
```

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

The `post_dispatch_hook` is called, as you might have guessed it, after
the response is dispatched but before it gets sent back to the client.

These hooks have access to the entire request context, including the
`service` being called. You can use the service `extra` option to set
some custom settings that can then be used in this pre dispatch hook.

In the default generated application, [rack-parser](https://github.com/achiu/rack-parser)
is used to parse the body of json requests. By default, this uses the `JSON`
to parse the body. This can be [overwritten](https://github.com/achiu/rack-parser#content-type-parsing)
if you choose.

Say you want to use [Oj](https://github.com/ohler55/oj) instead. To do
that, edit the `config/sinatra_config.rb` file and change the following:

```ruby
  use Rack::Parser
```

to:

```ruby
  use Rack::Parser, :parsers => {
    'application/json' => proc { |body| Oj.dump body }
  }
```

Of course, you'll need to `require 'oj'` first and add it to your
Gemfile if use Bundler.


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
