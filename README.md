# S3-server

S3 is a Rails server that responds to the same calls Amazon S3 responds to. It is extremely useful for testing of S3 in a sandbox environment without actually making calls to Amazon, which not only require network, but also cost you precious dollars.


## Running
```bash
$ bundle exec rails s
```

## Development
```bash
$ rm -r storage && rm db/development.sqlite3 && bundle exec rake db:migrate
$ bundle exec rails s
```
