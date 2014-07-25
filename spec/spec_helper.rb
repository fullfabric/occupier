require File.expand_path("../../lib/occupier", __FILE__)

require 'faker'
require 'yaml'

RSpec.configure do |config|

  config.before(:all) do

    config      = YAML.load(ERB.new(File.read('config/mongo.yml')).result)[ "test" ]
    @connection = Mongo::Connection.new(config['host'], config['port'])

  end

  config.before(:each) do

    @connection.database_names.select { |name| name =~ /^FF_test_*/ }.map do |database_name|
      @connection.drop_database database_name
    end

  end


end
