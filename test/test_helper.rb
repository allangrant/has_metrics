require 'rubygems'

# Want to test the files here, in lib, not in an installed version of the gem.
$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'shoulda'
# require 'mocha'
require 'activerecord'
require 'sqlite3'
require 'has_metrics/metrics'