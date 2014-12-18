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

### Examples

Run the `bootscaf` binary on a `Post` scaffold/model: 

```sh
bootscaf update posts
```

## Extras

There are a few conveniences added that we use in the vast majority of our projects. They are:

1) Helper css class names on the `<body>` element for page-specific CSS: 

```erb
<body class="controller-<%= controller.controller_name.dasherize %> action-<%= controller.action_name.dasherize %>">
```

2) Google analytics if an environment variable is set:

```ruby
ENV[“GOOGLE_ANALYTICS_ID"]
```

3) A click-to-select css selector for read-only inputs:

```html
<input class="select-all-on-click" type="text" value="long value" readonly>
```

4) Page `<title>`s set in views:

```erb
<% content_for :page_title do %>
Edit Model — 
<% end %>
```

And that’s about it, for now!

## Running Tests

`bundle exec rspec spec`

## Contributing

1. Fork it ( https://github.com/thrivesmart/bootscaf/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
