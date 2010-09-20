require 'rubygems'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'sequel'
require 'sequel_fast_columns'

require 'spec'
require 'spec/autorun'

TEST_DB = Sequel.sqlite
TEST_DB.create_table(:a) do
  integer :id
  integer :foo
end

TEST_DB.create_table(:b) do
  integer :id
  integer :bar
end

Spec::Runner.configure do |config|
  
end
