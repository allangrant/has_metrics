require 'spec_helper'

describe Segmentation do
  before do
    create_tables_for(:post)

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
  end

  describe "defining segments" do
    before do
      Post.create(:name => "Shorty")
      Post.create(:name => "Seven!!")
      Post.create(:name => "Really long")
      Post.update_all_metrics!
    end

    it "segments properly" do
      PostMetrics.count(:group => :by_name_length).should == {'short'=>1, 'seven'=>1, 'long'=>1}
    end
  end
end
