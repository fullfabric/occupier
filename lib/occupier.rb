# encoding: UTF-8

require 'rubygems'
require 'mongo_mapper'

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

end

require 'occupier/railtie' if defined?(Rails)
