# HasMetrics

Calculates metrics on ActiveRecord entries and caches them.

## Installation

Add this line to your application's Gemfile:

    gem 'has_metrics'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install has_metrics

## Usage

    has_metric :total_offer_count do
      activities.by_action(:offer).count
    end

    has_metric :average_shares_per_offer, :type => :float do
      total_share_count.to_f / total_offer_count
    end


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
