require File.expand_path("../../lib/occupier", __FILE__)

require 'byebug'

require 'faker'
require 'yaml'

require 'mongo'

RSpec.configure do |config|

  config.before(:all) do
    Mongo::Logger.level = 4
    config = YAML.load(ERB.new(File.read('config/mongo.yml')).result)[ "test" ]
    @_spec_client = Mongo::Client.new(["#{config['host']}:#{config['port']}"])
  end

  config.before(:each) do
    @_spec_client.database_names.select { |name| name =~ /^FF_test_*/ }.map do |database_name|
      @_spec_client.use(database_name).database.drop
    end
  end

end
