# Bootscaf

[![Build Status](https://travis-ci.org/thrivesmart/bootscaf.svg)](https://travis-ci.org/thrivesmart/bootscaf)

Bootscaf is a ruby gem that turns the default `rails generate scaffold`s into fully bootstrappified scaffolds.

Read more in the original blog post.

* Supported [Bootstrap](http://getbootstrap.com/) Version: `3.x`
* Supported [JQuery](http://jquery.com/) Version: `2.x`
* Supported [Ruby on Rails](http://rubyonrails.org/) Version: `4.x`

## Installation

Get it going in your `Gemfile`:

```ruby
    gem 'bootscaf', group: :development
```

Install it with `bundle` from your command line:

```sh
bundle
```

## Usage

Run the `bootscaf` binary on a single scaffold (e.g. `users`) from your rails project's base directory: 

```sh
bootscaf update NNNs
```

__OR__ Run `bootscaf` binary on all scaffolds:


```sh
bootscaf update --all
```

Of course, get help any time simply by running the naked `bootscaf` binary:

```sh
bootscaf
```

## Running Tests

`bundle exec rspec spec`

## Contributing

1. Fork it ( https://github.com/thrivesmart/bootscaf/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
