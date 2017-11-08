# encoding: UTF-8

require 'rubygems'
require 'contracts'
require 'mongo_mapper'

require 'pg'
require 'active_record'


module Occupier

  autoload :Tenant,             'occupier/tenant'

  autoload :Exception,          'occupier/exceptions'
  autoload :NotFound,           'occupier/exceptions'
  autoload :AlreadyExists,      'occupier/exceptions'
  autoload :InvalidTenantName,  'occupier/exceptions'

  module Mongo
    autoload :Connection, 'occupier/mongo/connection'
  end

  module MongoMapper
    autoload :Connection, 'occupier/mongo_mapper/connection'
  end

  module Pg
    autoload :Connection, 'occupier/pg/connection'
  end

end
