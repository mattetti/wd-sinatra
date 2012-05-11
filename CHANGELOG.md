# Weasel Diesel Sinatra Changelog

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
