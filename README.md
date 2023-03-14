# HopSkipDrive API

## Prerequisites

The setups steps expect following tools installed on the system.

- Ruby 3.2.1
- Rails 7.0.4.2

##### Installation

```bash
git clone git@github.com:nleffers/hop_skip_drive_api.git
```

##### 2. Install

```bash
bundle install
```

##### 3. Create and setup the database

Run the following commands to create and setup the database.

```ruby
bundle exec rake db:create
bundle exec rake db:migrate
```

##### 4. Start the Rails server

You can start the rails server using the command given below.

```ruby
bundle exec rails s
```

And now you can visit the site with the URL http://localhost:3000

## API Endpoints

#### Note: Drivers must be logged in to access the following endpoints

### Get List of Open Rides

#### Request

##### GET /rides/search\_open\_rides

#### Response

```bash
[{ id: 1, score: 25 }]
```
