require File.expand_path("../../lib/occupier", __FILE__)

require "faker"
require "yaml"
require "byebug"

RSpec.configure do |config|

  config.filter_run_when_matching :focus

  config.before(:all) do
    config  = YAML.load(ERB.new(File.read('config/mongo.yml')).result)["test"]
    @client = Mongo::Client.new(["#{config['host']}:#{config['port']}"])
  end

  config.before(:each) do
    @client.database_names.select { |name| name =~ /^FF_test_*/ }.map do |database_name|
      @client.use(database_name).database.drop
    end
  end

end
