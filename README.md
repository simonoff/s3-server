# S3-server

S3-server is a Rails server that responds to the same calls Amazon S3 responds to. It is extremely useful for testing of S3 in a sandbox environment without actually making calls to Amazon, which not only require network.

S3-server doesn't support all of the S3 command set, but the basic ones like put, get, list, copy, multipart uploads, and make bucket are supported. More coming soon.

## Running
```bash
$ bundle exec rails server -p 10001
```

- Running with docker
```bash
$ docker run -p 10001:10001 -d mdouchement/s3-server
```

## Connecting to S3-server
This application is mainly tested with the [AWS Ruby SDK](https://github.com/aws/aws-sdk-ruby).

Here is a running list of [supported clients](https://github.com/mdouchement/s3-server/wiki/Supported-clients)

## Development
```bash
$ rm -r storage ; rm db/development.sqlite3 ; bundle exec rake db:migrate
$ bundle exec rails s -p 10001
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
