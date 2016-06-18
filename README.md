Feed Filter
===========

Provides feeds with your filtering rules.

- https://syon-feed-filter.herokuapp.com/


## Dev

### Install

```sh
$ npm install
$ brew install postgresql
$ gem install foreman
$ bundle install --path vendor/bundle
```

### Migration

```sh
$ bundle exec ruby migrate.rb

$ bundle exec rake db:seed
```

### Local running

```sh
# Debug
$ npm run watch

# Production
$ npm run build
```

```sh
$ foreman start
```
