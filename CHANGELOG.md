# Weasel Diesel Sinatra Changelog

## 1.0.4
* Minor change to the Rakefile to support the new
  `wd_sinatra_active_record` gem.
* Calling `WDSinatra::AppLoader.set_loadpath` now requires a root path
  (used to be optional) and sets the app's root path if not set already.

## 1.0.3
* Bug release due to a problem with requiring the new `WSList
  extension`.

## 1.0.2
* Fixed a bug with the way sinatra routes are loaded. Because the routes
  can contain a globing param, the loading had to be changed to be
  smarter to globbing routes are loaded last.

## 1.0.1
* Added dependency on `WeaselDiesel` `1.2.0` or greater since the API
  slightly changed.

## 1.0.0
* It's time for WD to graduate, it's been behaving well in production
  for a while and no major problems were reported. A new rake task was
added in the default Rakefile to print the routes. But besides that,
this version didn't add anything major to 0.3.2

## 0.3.2
* Removed `post_dispatch_hook` since it doesn't work well with `halt`
  and file responses. Use Sinatra's `after` filter instead.
* Fixed a bug with `params_postprocessor_hook`.
* Added a 'wd.service' entry to `env` that points to the dispatched
  service.

## 0.3.1

* Added `post_dispatch_hook`.
* Fixed a few default settings.

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
