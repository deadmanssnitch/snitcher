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

The default timeout of 5 seconds can be overridden:

```ruby
Snitcher.snitch("c2354d53d2", timeout: 10)
```

## API Access

### Retrieving Your API Key At Command Line

```ruby
require "snitcher/api"

agent = Snitcher::API.get_key("jane@example.com", "password")
```

Returns a the `api_key` key string.

### Setup

Initialize the API client directly with your api_key:

```ruby
require "snitcher/api"

client = Snitcher::API::Client.new(api_key: "FOO")
```

### Listing Snitches

```ruby
client.snitches
```

Returns an array of snitches.

### Retrieve a Single Snitch

```ruby
token = "c2354d53d2"
client.snitch(token)
```

Returns a snitch.

### Retrieve Snitches That Match a Set of Tags

```ruby
tags = ["critical", "sales"]
client.tagged_snitches(tags)
```

Returns an array of snitches.

### Create a Snitch

Required attributes are name and interval. Optional attributes are notes and tags.

```ruby
attributes = { "name": "Nightly User Data Backups",
  "interval": "daily",
  "notes": "User login and usage data",
  "tags": ["users", "critical"]
}
client.create_snitch(attributes)
```

Returns the newly-created snitch.

### Edit a Snitch

You only need to pass the edit_snitch function the attributes you want to change. The rest of a snitch's attributes will remain the same.

```ruby
token = "c2354d53d2"
new_attributes = { "name": "Important Nightly User Data Backups" }
client.edit_snitch(token, new_attributes)
```

Returns the edited snitch.

### Adding Tags to a Snitch

This function adds tags to a snitch, retaining whatever tags it already has.

```ruby
token = "c2354d53d2"
tags = ["spring_campaign", "support"]
client.add_tags(token, tags)
```

Returns an array of all of the snitch's tags.

### Deleting a Tag From a Snitch

This function is for deleting a single tag from a snitch.

```ruby
token = "c2354d53d2"
tag = "support"
client.remove_tag(token, tag)
```

Returns an array of all of the snitch's remaining tags.

### Replace Tags on a Snitch

Replaces all of a snitch's tags with an array of new tags.

```ruby
token = "c2354d53d2"
tags = ["csv", "server_a"]
client.replace_tags(token, tags)
```

Returns the updated snitch.

### Remove Tags From a Snitch

Removes all of a snitch's tags.

```ruby
token = "c2354d53d2"
client.clear_tags(token)
```

Returns the updated snitch.

### Pause a Snitch

```ruby
token = "c2354d53d2"
client.pause_snitch(token)
```

Returns a hash with a `message` key, whose value is "Response complete".

### Delete a Snitch

```ruby
token = "c2354d53d2"
client.delete_snitch(token)
```

Returns a hash with a `message` key, whose value is "Response complete".

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
