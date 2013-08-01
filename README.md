# Snitcher

Simple API client for [Dead Man's Snitch](https://deadmanssnitch.com)

![Snitches get Stitches](doc/get_them_stitches.jpg)

## Basic Usage

Notify Dead Man's Snitch that a thing happened:
```ruby
Snitcher.snitch("c2354d53d2")
```

## Usage as a mixin
```ruby
class SnitchingThing
  include Snitcher
  snitch_on "token1234"

  def method_that_does_work
    # I JUST DID A BUNCH OF WORK

    # I should probably tell somebody I'm done!
    snitch!
    # Yay! Now deadmanssnitch is aware I'm done!
  end
```


## Note on Patches/Pull Requests

* Fork the project.
* Add tests to show the problem or test your feature
* Make your feature addition or bug fix.
* Send me a pull request. Bonus points for topic branches.

Please don't make changes to the Rakefile or version.

## Copyright

See LICENSE for details.
