# include Segmentation
module Segmentation
  def self.included(base)
    base.extend ClassMethods
  end
  
  # CLASS METHODS ADDED
  module ClassMethods
    def segment_by category, &definition
      (@segment_categories ||= []) << category.to_sym
      define_method("segment_by_#{category}", definition)
      if respond_to?(:has_metric)
        has_metric "by_#{category}" do
          send("segment_by_#{category}")
        end
      end
    end
    def segment_categories
      @segment_categories
    end
    def update_segments!
      puts "Updating all segments on #{name}: #{segment_categories.join(', ')}"
      all.each do |object|
        segment_categories.each do |category|
          object.update_segment!(category)
        end
      end
    end
  end # END OF CLASS METHODS

  # INSTANCE METHODS ADDED
  def update_segment!(category)
    update_attribute("by_#{category}", send("segment_by_#{category}"))
  end
  # END OF INSTANCE METHODS
end
