module Occupier
  class Railtie < Rails::Railtie # :nodoc:
    config.occupier = ActiveSupport::OrderedOptions.new
    config.occupier.dbs = ActiveSupport::OrderedOptions.new
    config.occupier.dbs.log = false
  end
end
