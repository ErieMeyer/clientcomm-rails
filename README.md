# clientcomm-rails

[![CircleCI](https://circleci.com/gh/codeforamerica/clientcomm-rails.svg?style=svg)](https://circleci.com/gh/codeforamerica/clientcomm-rails)
[![Code Climate](https://codeclimate.com/github/codeforamerica/clientcomm-rails/badges/gpa.svg)](https://codeclimate.com/github/codeforamerica/clientcomm-rails)
[![Test Coverage](https://codeclimate.com/github/codeforamerica/clientcomm-rails/badges/coverage.svg)](https://codeclimate.com/github/codeforamerica/clientcomm-rails/coverage)

A rails port/reimagining of [ClientComm](https://github.com/slco-2016/clientcomm).

## Installation
### Requirements
1. Install Ruby with your ruby version manager of choice, like [rbenv](https://github.com/rbenv/rbenv) or [RVM](https://github.com/codeforamerica/howto/blob/master/Ruby.md)
2. Check the ruby version in `.ruby-version` and ensure you have it installed locally e.g. `rbenv install 2.4.0`
3. [Install Postgres](https://github.com/codeforamerica/howto/blob/master/PostgreSQL.md). If setting up Postgres.app, you will also need to add the binary to your path. e.g. Add to your `~/.bashrc`:
`export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin"`

## Setup

1. Install [bundler](https://bundler.io/): `gem install bundler`
2. Install other requirements: `bundle install`
3. Create the databases: `rails db:create`
4. Apply the schema to the databases:
```
rails db:schema:load RAILS_ENV=development
rails db:schema:load RAILS_ENV=test
```
5. Install [Foreman](https://github.com/ddollar/foreman) or the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli#download-and-install)
6. Copy `.env.example` to `.env` and fill in the relevant values.
7. Start the server with `foreman start` or `heroku local`. Take note of the port the server is running on, which may be set with the `PORT` variable in your `.env` file.

## Setting Up Twilio

1. Buy an SMS-capable phone number on [Twilio](https://www.twilio.com/). You can use [the web interface](https://www.twilio.com/console/phone-numbers/search), or [this script](https://gist.github.com/cweems/e3fb8ab69c6e0776e492d88672a4ded9).
2. Install [ngrok](https://ngrok.com/). You can use `npm install -g ngrok` if you are running npm on your machine, or [download the binary](https://ngrok.com/download) and [create a symlink](https://gist.github.com/wosephjeber/aa174fb851dfe87e644e#creating-a-symlink-to-ngrok).
3. Start ngrok by entering `ngrok http 3000` in the terminal to start a tunnel (replace `3000` with the port your application is running on if necessary). You should see an ngrok url displayed, e.g. `https://e595b046.ngrok.io`.
4. When your Twilio number receives an sms message, it needs to know where to send it. The application has an endpoint to receive Twilio webhooks at, for example, `https://e595b046.ngrok.io/incoming/sms/`. Click on your phone number in [the Twilio web interface](https://www.twilio.com/console/phone-numbers/incoming) and enter this URL (with your unique ngrok hostname) in the *A MESSAGE COMES IN* field, under *Messaging*.
  
   Alternately, you can use [this script](https://gist.github.com/cweems/83980eaec208941256da8823ebf71a5e) to find your phone number's SID, then use [this script](https://gist.github.com/cweems/88560859525ddd4b19e0eaf71f5bbd17) to update the Twilio callback with your ngrok url.

## Testing

- [Phantom](http://phantomjs.org/) is required to run some of the feature tests. [Download](http://phantomjs.org/download.html) or install with [Homebrew](https://brew.sh/): `brew install phantom`
- Test suite: `bin/rspec`. For more detailed logging use `bin/rspec LOUD_TESTS=true`.
- File-watcher: `bin/guard` when running will automatically run corresponding specs when a file is edited.

## Contact

Tomas Apodaca ( @tmaybe )
