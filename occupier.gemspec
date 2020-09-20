# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'version'

Gem::Specification.new do |s|

  s.name        = "occupier"
  s.version     = Occupier::VERSION
  s.authors     = [ "Luis Correa d'Almeida" ]
  s.email       = [ "luis@fullfabric.com" ]
  s.summary     = "Occupier"
  s.description = "The Occupier gem provides support for multi-tenancy on mongodb"

  s.required_ruby_version = ">= 2.6"

  s.add_dependency "mongo", "~> 1"
  s.add_dependency "bson", "~> 1"
  s.add_dependency "bson_ext", "~> 1"
  s.add_dependency "mongo_mapper", ">= 0.13.1"
  s.add_dependency "mongo_ext"
  s.add_dependency "pg"

  s.add_development_dependency "faker", "2.2.1"
  s.add_development_dependency "rb-fsevent"
  s.add_development_dependency "awesome_print"

  s.files        = Dir.glob("{lib}/**/*")
  s.require_path = 'lib'

end
