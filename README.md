build:

```
coffee -w -o . *.coffee
```

run server:

```
rerun "ruby -rubygems config.ru" -p 'config.ru'
```

run specs:

```
rerun "clear; node spec.js" -p spec.js
```
