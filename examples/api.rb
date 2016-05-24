$:.unshift File.expand_path("../../lib", __FILE__)

# Need to require the API separately as it is not required by Snitcher itself.
require "snitcher/api"

if !(ENV["DMS_USER"] && ENV["DMS_PASS"])
  puts "Set DMS_USER and DMS_PASS environment variables to your"
  puts "deadmanssnitch.com credentials before running this example"
  puts
  puts "example: DMS_USER=email DMS_PASS=pass ruby examples/api.rb"

  exit 1
end

# Get an API key for a given user with password
key = Snitcher::API.get_key(ENV["DMS_USER"], ENV["DMS_PASS"])

# Create a new API client
client = Snitcher::API::Client.new(key)

# Create an hourly Snitch called "Monitor All The Things"
snitch = client.create_snitch({
  name: "Monitor All The Things",
  tags: ["things"],
  interval: "hourly",
})
puts "Created: #{snitch.inspect}"

# Change the name and notes of an existing Snitch
snitch = client.update_snitch(snitch.token, {
  name: "Monitor Fewer Things",
  notes: "Only monitoring a couple things",
})

# Add new tags to a Snitch
snitch.tags = client.add_tags(snitch.token, ["production", "critical issues"])

# Remove the "critical issues" tag from the Snitch
snitch.tags = client.remove_tag(snitch.token, "critical issues")

# Get a list of Snitches tagged with "production"
production = client.tagged_snitches(["production"])
puts "Production Snitches:"
production.each { |s| puts "  - #{s.inspect}"}

# Pause a Snitch if it's currently missing or errored
client.pause_snitch(snitch.token)

# Delete a Snitch
client.delete_snitch(snitch.token)
puts "Deleted: #{snitch.token}"
