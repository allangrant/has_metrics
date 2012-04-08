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
      root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
      
      CreateTestTables.up
      User.update_all_metrics!
      @user_name =
      @user = User.create(:name => "Fuzz")
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

    should "they should calculate their block when called" do
      assert_equal "Fuzz", @user.name
      assert_equal 4, @user.name_length
      @user.name = "Bib"
      assert_equal 3, @user.name_length
      assert_equal 4, User.find_by_name("Fuzz").name_length
    end
  end
end
