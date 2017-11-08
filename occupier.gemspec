# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'version'

Gem::Specification.new do |s|

  s.name        = "occupier"
  s.version     = Occupier::VERSION
  s.authors     = [ "Luis Correa d'Almeida" ]
  s.email       = [ "luis@fullfabric.com" ]
  s.summary     = "Occupier"
  s.description = "The Occupier gem provides support for multi-tenancy on mongodb and postgres"

  s.add_dependency "mongo"
  s.add_dependency "bson"
  s.add_dependency "bson_ext"
  s.add_dependency "mongo_mapper", '0.13.1'
  s.add_dependency "mongo_ext"
  s.add_dependency "pg"

  s.add_development_dependency "rspec"
  s.add_development_dependency "faker"
  s.add_development_dependency "rb-fsevent"

  s.files        = Dir.glob("{lib}/**/*")
  s.require_path = 'lib'

end
