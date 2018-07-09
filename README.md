# Snitcher

Simple API client for [Dead Man's Snitch](https://deadmanssnitch.com)

[![Gem Version](https://badge.fury.io/rb/snitcher.png)](http://badge.fury.io/rb/snitcher)
[![Build Status](https://travis-ci.org/deadmanssnitch/snitcher.png?branch=master)](https://travis-ci.org/deadmanssnitch/snitcher)
[![Code Climate](https://codeclimate.com/github/deadmanssnitch/snitcher.png)](https://codeclimate.com/github/deadmanssnitch/snitcher)
[![Coverage Status](https://coveralls.io/repos/deadmanssnitch/snitcher/badge.png)](https://coveralls.io/r/deadmanssnitch/snitcher)

![Snitches get Stitches](doc/get_them_stitches.jpg)

## Usage

To check in for one of your snitches:

```ruby
Snitcher.snitch("c2354d53d2")
```

You also may provide a message with the check in:

```ruby
Snitcher.snitch("c2354d53d2", message: "Finished in 23.8 seconds.")
```

Errors can be reported by providing the `status` option. A status of `nil`,
`0`, or `""` are all considered a success. Any other status is treated as a
failure.

```ruby
Snitcher.snitch("c2354d53d2", status: 1)
```

The default timeout of 5 seconds can be overridden:

```ruby
Snitcher.snitch("c2354d53d2", timeout: 10)
```

## API Access

### Setup

Initialize the API client directly with your api key:

```ruby
require "snitcher/api"

client = Snitcher::API::Client.new("my_awesome_key")
```

#### Heroku

Dead Man's Snitch exposes the `DEADMANSSNITCH_API_KEY` environment variable for
accessing the API.

```ruby
require "snitcher/api"

client = Snitcher::API::Client.new(ENV["DEADMANSSNITCH_API_KEY"])
```

### Listing Snitches

```ruby
client.snitches
```

Returns an array of Snitches.

### Retrieve a Single Snitch

```ruby
token = "c2354d53d2"
client.snitch(token)
```

Returns a Snitch.

### Retrieve Snitches That Match a Set of Tags

```ruby
client.snitches(tags: ["critical", "sales"])
```

Returns an array of Snitches.

### Create a Snitch

Both `:name` and `:interval` are required. Optional attributes include `:notes`,
and `:tags`. For a full list see [the API documentation](https://deadmanssnitch.com/docs/api/v1#creating-a-snitch).

```ruby
attributes = {
  name: "Nightly User Data Backups",
  interval: "daily",
  notes: "User login and usage data",
  tags: ["users", "critical"],
}
client.create_snitch(attributes)
```

Returns the newly-created Snitch.

### Updating a Snitch

You only need to pass the update_snitch function the attributes you want to
change. The rest of a Snitch's attributes will remain the same.

```ruby
token = "c2354d53d2"
attrs = { "name": "Important Nightly User Data Backups" }
client.update_snitch(token, attrs)
```

Returns the edited Snitch.

### Adding Tags to a Snitch

This function adds tags to a Snitch, retaining whatever tags it already has.

```ruby
token = "c2354d53d2"
tags  = ["spring_campaign", "support"]
client.add_tags(token, tags)
```

Returns an array of all of the Snitch's tags.

### Deleting a Tag From a Snitch

This function is for deleting a single tag from a Snitch.

```ruby
token = "c2354d53d2"
tag = "support"
client.remove_tag(token, tag)
```

Returns an array of all of the Snitch's remaining tags.

### Setting the Tags on a Snitch

```ruby
token = "c2354d53d2"
client.update_snitch(token, tags: [ "production", "critical" ])
```

### Removing all Tags from a Snitch

```ruby
token = "c2354d53d2"
client.update_snitch(token, tags: [])
```

### Pause a Snitch

```ruby
token = "c2354d53d2"
client.pause_snitch(token)
```

Returns a nil object.

### Delete a Snitch

```ruby
token = "c2354d53d2"
client.delete_snitch(token)
```

Returns a nil object.

## Contributing

Snitcher is open source and contributions from the community are encouraged! No
contribution is too small. Please consider:

* adding features
* squashing bugs
* updating documentation
* fixing typos

For the best chance of having your changes merged, please:

1. fork the project
2. push your changes, with tests
3. submit a pull request with at least one animated GIF

## Thanks

A big thank you to [Randy Schmidt](https://github.com/r38y) for dreaming up
Dead Man's Snitch in the first place and for
[entrusting](http://r38y.com/dead-mans-snitch-sold) its future to Collective
Idea.

## Copyright

See [LICENSE.txt](LICENSE.txt) for details.
