# DriveConnectorApi

DriveConnectorApi enables drivers to select the best rides for them from all rides available.

## Prerequisites

This setup uses the following tools:

- Ruby 3.2.1
- Rails 7.0.4.2

This API uses the OpenRouteService API to get Location and Route information

## Installation

##### 1. Clone repository

    git clone git@github.com:nleffers/hop_skip_drive_api.git

##### 2. Install

    gem install bundler
    bundle install

##### 3. Create and setup the database

Run the following commands to create and setup the database.

    rails db:create
    rails db:migrate

##### 4. Start the Rails server

You can start the rails server using the command given below.

    rails s

And now you can visit the site with the URL http://localhost:3000

---

## API Endpoints

#### Note: Drivers must be logged in to use the following endpoints

### Get List of Open Rides

##### - Returns a list of open rides available to a driver

#### Request

`GET /rides/search_open_rides`

#### Response

```ruby
[
  {
    id: 1,
    score: 25
  },
  ...
]
```
