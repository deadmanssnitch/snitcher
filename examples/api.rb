$:.unshift File.expand_path("../../lib", __FILE__)

require "pry"
require "snitcher/api"

# Get an API key for a given user with password
key = Snitcher::API.get_key(ENV["DMS_USER"], ENV["DMS_PASS"])
# Create a new API client
client = Snitcher::API::Client.new(key)

# Create an hourly Snitch called Test Snitch

attributes = { "name": "Test Snitch",
               "interval": "hourly" }
snitch = client.create_snitch(attributes)

# Update the attributes of a Snitch with a given token

new_attributes = { "name": "New Name",
                   "interval": "daily" }
snitch = client.update_snitch(snitch.token, new_attributes)

# Add tags to a Snitch with a given token

tags = [ "tag 1", "tag 2"]
snitch.tags = client.add_tags(snitch.token, tags)

# Deleting tags from a snitch with a given token

tag = "tag 1"
snitch.tags = client.remove_tag(snitch.token, tag)

# Get a list of snitches that match tags 

tags = [ "new tag 2" ]
client.tagged_snitches(tags) # => snitch with tag "new tag 2"

# Pause a snitch with a given token

client.pause_snitch(snitch.token)

# Delete a snitch with a given token

client.delete_snitch(snitch.token)
