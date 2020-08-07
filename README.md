# Occupier

Handle connecting to different tenant databases in Mongo

## Tenants

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

## Databases

You can also access databases directly.

    connection = Occupier::Mongo::Connection.new :development
    connection.database!("FF_development_tbs")

If a database does not exist, the method above will raise an error. If you need access to a database that does not exist, use

    connection.database("FF_development_tbs")

## Documentation
Generate documentation for this project using YARD
    
    yardoc
