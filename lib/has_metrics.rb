require "has_metrics/version"
require "has_metrics/metrics"
require "has_metrics/segmentation"

module HasMetrics
  def self.included(base)
    base.send :include, Metrics
    base.send :include, Segmentation
  end
end
