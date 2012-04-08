# HasMetrics

Calculates metrics on ActiveRecord entries and caches them so they can be queried from a database.  The calculated values are stored in another table which gets automatically created and migrated as needed.

## Installation

Add this line to your application's Gemfile:

    gem 'has_metrics'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install has_metrics

## Usage

    # Memoize in DB for 24 hours as an integer
    has_metric :total_offer_count do
      activities.by_action(:offer).count
    end

    # Memoize in DB for 1 hour as an integer
    has_metric :total_share_count, :every => 1.hour do
      activities.by_action(:share).count
    end

    # Memoize in DB for 24 hours as a float
    has_metric :average_shares_per_offer, :type => :float do
      total_share_count.to_f / total_offer_count
    end

## TODO

1. Tests
2. Refactoring
3. Better readme
4. Extract related functionality into gem
    * segments - lets you use has_metrics to segment all records in a table between some set of string values
    * has_custom_order_by - provides default names scopes for sorting based on metrics & segments by joining the metrics table

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
