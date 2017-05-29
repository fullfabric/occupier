# encoding: UTF-8
require 'rubygems'
require 'yaml'
require 'erb'
require 'mongo'

module Occupier

  autoload :Tenant,             'occupier/tenant'

  autoload :Exception,          'occupier/exceptions'
  autoload :NotFound,           'occupier/exceptions'
  autoload :AlreadyExists,      'occupier/exceptions'
  autoload :InvalidTenantName,  'occupier/exceptions'

  autoload :RequestMiddleware,  'occupier/middleware/request_middleware'
  autoload :HostMiddleware,  'occupier/middleware/host_middleware'

  module Helpers
    autoload :Hosts,  'occupier/middleware/helpers/hosts'
  end

  module Mongo
    autoload :Client, 'occupier/mongo/client'
  end

end
