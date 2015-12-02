# Export prototype

This prototype is based on [middleman](https://middlemanapp.com/), a static site generator, and [mojular](https://github.com/mojular) for common [GOV.UK](https://gov.uk/) layouts and patterns.

## Dependencies

* [Ruby](https://www.ruby-lang.org/en/)
* [Node.js](https://nodejs.org/en/)
* [Foreman](http://ddollar.github.io/foreman/) (for development only)

## Installation

1. Clone repository:

  ```
  git clone https://github.com/UKTradeInvestment/export-prototype
  ```

2. Install ruby dependencies:

  ```
  bundle install
  ```

3. Install node dependencies:

  ```
  npm install
  ```

4. 
  Build static files from source to `./build/`:
  
  ```
  middleman build
  ```

  **OR**

  Run a middleman server

  ```
  middleman server
  ```

## Deployment

The app is currenlty deployed to [Heroku](http://heroku.com/) where it runs a [rack](http://rack.github.io/) application serving the static files.

There is a [production environment](https://export-prototype.herokuapp.com/) which is automatically deployed on changes to the `master` branch and a [development environment](https://export-prototype-dev.herokuapp.com/) which is automatically deployed on changes to the `develop` branch.

Having two environments allows changes to be made to the development environment whilst the production environment might be being used for a user testing session.

The site may be protected by a username and password. If you have access to the heroku app these will be stored as environment variables.

If you have the [heroku toolbelt](https://toolbelt.heroku.com/) installed you can check environment variables by running:

```
heroku config
```

## Development

Assets are compiled using [webpack](https://webpack.github.io/). [Foreman](http://ddollar.github.io/foreman/) can be used to simultaneously run a middleman server and a webpack module bundler.

Run:

```
foreman start --procfile dev.Procfile
```
