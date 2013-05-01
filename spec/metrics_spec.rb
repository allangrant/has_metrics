require 'spec_helper'

describe Metrics do
  describe "defining metrics" do
    let(:user) { User.create(:name => "Fuzz") }

    before do
      create_tables_for(:user)

      class User < ActiveRecord::Base
        include Metrics
        has_metric :name_length do
          name.length
        end
      end

      User.update_all_metrics!
    end

    it "creates rows for the metrics" do
      UserMetrics.columns.count.should == 3
      User.has_metric :name_length_squared do
        name_length * name_length
      end
      User.update_all_metrics!
      UserMetrics.columns.count.should == 5
      user.name_length_squared.should == 16
    end

    it "calculates their block when called" do
      user.name.should == "Fuzz"
      user.name_length.should == 4

      user.name = "Bib"

      # since 20 hours hasn't passed, the value is pulled from cache, not recalculated
      user.name_length.should == 4
      # (true) forces it to recalculate right away
      user.name_length(true).should == 3

      # since it wasn't saved, it's the same in the DB
      User.find_by_name("Fuzz").name_length.should == 4

      user.save
      user.name_length(true).should == 3
      User.find_by_name("Bib").name_length.should == 3
    end

    it "has their values precomputed" do
      user
      User.update_all_metrics!
      UserMetrics.count(:group => :name_length).should == {4=>1}
    end
  end
end
