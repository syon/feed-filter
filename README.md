Feed Filter
===========

Provides feeds with your filtering rules.


### Required

- Node packages  
[Tooling Integration | React](https://facebook.github.io/react/docs/tooling-integration.html)
```js
$ npm install --save react react-dom
$ npm install --global babel
$ npm install babel-preset-es2015 babel-preset-react
```
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
$ babel --presets es2015,react babel/ --out-dir public/
$ babel --presets es2015,react babel/ --out-dir public/ --watch
```
```sh
$ foreman start
```
