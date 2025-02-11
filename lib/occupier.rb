# encoding: UTF-8

require 'rubygems'
require 'mongo_mapper'
require 'active_record'
require_relative 'occupier/postgres/extensions/custom_adapter'

module Occupier

  autoload :Tenant,             'occupier/tenant'

  autoload :Exception,          'occupier/exceptions'
  autoload :NotFound,           'occupier/exceptions'
  autoload :AlreadyExists,      'occupier/exceptions'
  autoload :InvalidTenantName,  'occupier/exceptions'

  module Mongo
    autoload :Client, 'occupier/mongo/client'
  end

  module MongoMapper
    autoload :Connection, 'occupier/mongo_mapper/connection'
  end

  module Postgres
    autoload :Client, 'occupier/postgres/client'
  end
end

require 'occupier/railtie' if defined?(Rails)
