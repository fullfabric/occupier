require File.expand_path("../../lib/occupier", __FILE__)

require 'faker'
require 'yaml'

RSpec.configure do |config|

  config.before(:all) do
    @conn_mongo = Occupier::Mongo::Connection.new("test")
    @conn_pg    = Occupier::Pg::Connection.new("test")
  end

  config.before(:each) do
    @conn_mongo.drop_all
    @conn_pg.drop_all

    @conn_mongo.close
    @conn_pg.close
  end

end
