require "has_metrics/version"
require "has_metrics/metrics"

module HasMetrics
  def self.included(base)
    base.send :include, Metrics
  end
end
