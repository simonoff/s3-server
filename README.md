# S3-server

**Only for development and test purpose.**

S3-server is a Rails server that responds to the same calls Amazon S3 responds to. It is extremely useful for testing of S3 in a sandbox environment without actually making calls to Amazon, which not only require network.

S3-server doesn't support all of the S3 command set, but the basic ones like put, get, list, copy, multipart uploads, and make bucket are supported. More coming soon.

## Running
```bash
$ bundle exec rails server -p 10001
```

- Running with docker

```bash
$ docker run -p 10001:10001 -d predicsis/s3-server
```

- Running with docker (with volumes)

```bash
$ docker run -p 10001:10001 -v /home/user/s3-server/storage:/data/storage -v /home/user/s3-server/db:/data/db -d predicsis/s3-server
```

- As service

```bash
$ docker run --restart=always --name=s3_server -p 10001:10001 -v /home/user/s3-server/storage:/data/storage -v /home/user/s3-server/db:/data/db -d predicsis/s3-server
```

## Adding to your tests (RSpec)
### Instalaltion
- `Gemfile`
```ruby
gem 's3_server'
```
- or `gemspec`
```ruby
spec.add_development_dependency 's3_server'
```

### Configuration
- `spec_helper.rb`
```ruby
require 's3_server/server'
RSpec.configure do |config|
  # ...
  config.before(:suite) { S3Server::Server.start }
  config.after(:suite) { S3Server::Server.stop }
  # ...
end
```

## Connecting to S3-server
This application is mainly tested with the [AWS Ruby SDK](https://github.com/aws/aws-sdk-ruby).

Here is a running list of [supported clients](https://github.com/mdouchement/s3-server/wiki/Supported-clients)

## Development
```bash
$ bundle exec rake db:migrate
$ bundle exec rails s -p 10001
```

## Test
```bash
$ bundle exec rails s -p 10001
$ bundle exec rake cucumber # It launches feature specs with Ruby AWS SDK V1 or v2
```

## License

MIT. See the [LICENSE](https://github.com/mdouchement/s3-server/blob/master/LICENSE) for more details.


## Contributing

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Ensure specs and Rubocop pass
5. Push to the branch (git push origin my-new-feature)
6. Create new Pull Request

## More Information
Check out the [wiki](https://github.com/mdouchement/s3-server/wiki)
