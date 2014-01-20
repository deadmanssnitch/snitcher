# Snitcher

Simple API client for [Dead Man's Snitch](https://deadmanssnitch.com)

[![Gem Version](https://badge.fury.io/rb/snitcher.png)](http://badge.fury.io/rb/snitcher)
[![Build Status](https://travis-ci.org/collectiveidea/snitcher.png?branch=master)](https://travis-ci.org/collectiveidea/snitcher)
[![Code Climate](https://codeclimate.com/github/collectiveidea/snitcher.png)](https://codeclimate.com/github/collectiveidea/snitcher)
[![Coverage Status](https://coveralls.io/repos/collectiveidea/snitcher/badge.png)](https://coveralls.io/r/collectiveidea/snitcher)
[![Dependency Status](https://gemnasium.com/collectiveidea/snitcher.png)](https://gemnasium.com/collectiveidea/snitcher)

![Snitches get Stitches](doc/get_them_stitches.jpg)

## Usage

To check in for one of your snitches:

```ruby
Snitcher.snitch("c2354d53d2")
```

You can also check in from the command line:

```bash
$ snitch c2354d53d2
```

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
3. submit a pull request with at least on animated GIF

## Thanks

A big thank you to [Randy Schmidt](https://github.com/r38y) for dreaming up
Dead Man's Snitch in the first place and for
[entrusting](http://r38y.com/dead-mans-snitch-sold) its future to Collective
Idea.

## Copyright

See [LICENSE.txt](LICENSE.txt) for details.
