At first, you need to install all the required dependencies:
```
bundle install
```

build:

```
bundle exec rakep
```

run server:

```
rerun "ruby -rubygems config.ru" -p 'config.ru'
```

run specs:

```
rerun "clear; node spec.js" -p spec.js
```

capture the log when you see a bug before the log gets aggregated (3 min after build:finished):

```
# check the dom inspector for the log url, like https://api.travis-ci.org/jobs/5359675/log?cors_hax=true
$ curl -H "Accept: application/vnd.travis-ci.2+json; chunked=true; version=2, text/plain; version=2" [that_url] | pbcopy
# then gist that clipboard
```

taking a screenshot of the bug also will help a lot
