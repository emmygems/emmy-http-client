# EmmyHttp::Client

This gem is part of Emmy framework

> gem install emmy

## Usage

```ruby
response = Emmy.request(url: "http://httpbin.org/get").sync
```

or,

```ruby
request = Emmy.request(url: "http://httpbin.org/post", form: {param: 'foo'}).post.sync
```

Long way,

```ruby
request = EmmyHttp::Request.new(url: "http://google.com")
operation = EmmyHttp::Operation.new(request, EmmyHttp::Client::Adapter)
response = operation.sync
```

### Asynchronous requests

```ruby
Emmy.run_block {
  responses = {
      get_request:  Emmy.request!(url: "http://httpbin.org/get")
      post_request: Emmy.request!(url: "http://httpbin.org/post", type: "POST", form: {param: 'foo'})
  }.sync

  p responses[:get_request]
  p responses[:post_request]
}
```
