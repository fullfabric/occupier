# Occupier

Handle connecting to different tenant databases in Mongo

Creating a new tenant
    
    connection = Occupier::Mongo::Connection.new :development
    Occupier::Tenant.new("tbs", connection).create!

Connecting to an existing tenant
    
    connection = Occupier::Mongo::Connection.new :development
    Occupier::Tenant.new("tbs", connection).connect!

Connecting to an existing tenant using the short form

    Occupier::Tenant.connect!("tbs", environment)

Resetting a tenant
    
    connection = Occupier::Mongo::Connection.new :development
    Occupier::Tenant.new("tbs", connection).reset!

Generate documentation for this project using YARD
    
    yardoc