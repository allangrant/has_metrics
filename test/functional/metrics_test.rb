require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

ActiveRecord::Base.establish_connection(:adapter => "sqlite3",
  :database => File.expand_path(File.dirname(__FILE__) + "/../test.db"))

class CreateTestTables < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.string   "name"
    end
    create_table "user_metrics", :force => true
  end
  
  def self.down
    drop_table "users"
    drop_table "user_metrics"    
  end
end


class User < ActiveRecord::Base
  include Metrics
  has_metric :name_length do
    name.length
  end
end


class MetricsTest < Test::Unit::TestCase
  context "when defining metrics" do
    setup do
      CreateTestTables.up
      @user = User.create(:name => "Fuzz")
      User.update_all_metrics!
    end
    
    should "create rows for the metrics" do
      assert_equal 3, UserMetrics.columns.count
      User.has_metric :name_length_squared do
        name_length * name_length
      end
      User.update_all_metrics!
      assert_equal 5, UserMetrics.columns.count
      assert_equal 16, @user.name_length_squared
    end

    should "calculate their block when called" do
      assert_equal "Fuzz", @user.name
      assert_equal 4, @user.name_length

      @user.name = "Bib"

      # since 20 hours hasn't passed, the value is pulled from cache, not recalculated
      assert_equal 4, @user.name_length
      # (true) forces it to recalculate right away
      assert_equal 3, @user.name_length(true)
      
      # since it wasn't saved, it's the same in the DB
      assert_equal 4, User.find_by_name("Fuzz").name_length
      
      @user.save
      assert_equal 3, @user.name_length(true)
      assert_equal 3, User.find_by_name("Bib").name_length      
    end
    
    should "have their values precomputed" do
      assert_equal({4=>1}, UserMetrics.count(:group => :name_length))
    end
    
  end
end
