require File.expand_path("../../lib/occupier", __FILE__)

require "faker"
require "yaml"
require "byebug"

RSpec.configure do |config|
  config.filter_run_when_matching :focus

  config.before(:all) do
    config  = YAML.load(ERB.new(File.read('config/mongo.yml')).result)["test"]
    @client = Mongo::Client.new(["#{config['host']}:#{config['port']}"])
    @pg_config = YAML.load(ERB.new(File.read('config/database.yml')).result)['test']

    @pg_client = Occupier::Postgres::Client.new("test", nil)
  end

  config.before(:each) do
    ActiveRecord::Base.establish_connection(@pg_config)
    @client.database_names.select { |name| name =~ /^FF_test_*/ }.map do |database_name|
      @client.use(database_name).database.drop
    end
    @pg_client.database_names.map do |database_name|
      @pg_client.drop_database(database_name)
    end
  end
end
