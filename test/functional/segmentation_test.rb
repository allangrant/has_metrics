require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class Post < ActiveRecord::Base
  include Metrics
  include Segmentation

  segment_by :name_length do
    case name.length
    when 0..6
      "short"
    when 7
      "seven"
    else
      "long"
    end
  end
end

class SegmentationTest < Test::Unit::TestCase
  context "when defining segments" do
    setup do
      CreateTestTables.up(:post)

      Post.create(:name => "Shorty")
      Post.create(:name => "Seven!!")
      Post.create(:name => "Really long")
      Post.update_all_metrics!
    end
  
    should "segment properly" do
      assert_equal({'short'=>1, 'seven'=>1, 'long'=>1}, PostMetrics.count(:group => :by_name_length))
    end
  end
end
