Feed Filter
===========

Provides feeds with your filtering rules.


### Required

- Gems
  - bundler
  - foreman
- Database
  - SQLite3 (develoment)
  - PostgreSQL (production)


### Install

#### Install gems

```sh
$ bundle install --path vendor/bundle
```

#### Migration

```sh
$ bundle exec ruby migrate.rb

$ bundle exec rake db:seed
```


### Local running

```sh
$ foreman start
```
