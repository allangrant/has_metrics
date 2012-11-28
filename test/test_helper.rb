require 'rubygems'

# Want to test the files here, in lib, not in an installed version of the gem.
$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'shoulda'
# require 'mocha'
require 'active_record'
require 'sqlite3'
require 'has_metrics'
require 'pry'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => File.expand_path(File.dirname(__FILE__) + "/../test.db"))


class CreateTestTables < ActiveRecord::Migration
  def self.up(model = :user)
    create_table "#{model}s", :force => true do |t|
      t.string   "name"
    end
    create_table "#{model}_metrics", :force => true
  end
  
  def self.down(model = :user)
    drop_table "#{model}s"
    drop_table "#{model}_metrics"    
  end
end
