# Weasel Diesel Sinatra Changelog

## 0.3.0

* Added a service generator using thor. `$ thor :service get /foo/bar foo_bar.rb` (Thanks DrNic)

## 0.2.6

* Added a few basic disabled settings for newrelic and airbrake.

## 0.2.5

* added support for `ENV['DONT_LOAD_MODELS']` to avoid loading models.

## 0.2.4

* Fixed the documentation template to support namespaced input params.

## 0.2.3

* Fixed the example of the `params_exception_handler` hook added in the
  generated `hooks.rb` file.

## 0.2.2

* Added a `params_exception_handler` hook to customize the rescue of an
  exception being raised in the params processing phase.

## 0.2.1

* fixed the content type on the param verification error message

## 0.2.0

* moved `hooks.rb` and `app.rb` to `/lib`

* Automatically load the hooks in the loader if available


## 0.1.0

* Updated  `sinatra_config.rb` to automatically store exceptions in
  `rack.exception` so rack middleware like airbrake can properly make
  use of the exceptions without exposing any details to the end users.

* Added support for documenting the service params as they are defined.
  (thanks rwfowler)

```ruby
service.params do |p|
  p.string :email, :doc => "Email address of the recipient."
end
```

* Started porting test helpers to facilitate API testing.

* Updated the guard files. (thanks drnic)
