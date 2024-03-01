# Occupier

Handle connecting to different tenant databases in Mongo

## Tenants

Creating a new tenant

    client = Occupier::Mongo::Client.new :development
    Occupier::Tenant.new("tbs", client).create!

Connecting to an existing tenant

    client = Occupier::Mongo::Client.new :development
    Occupier::Tenant.new("tbs", client).connect!

Connecting to an existing tenant using the short form

    Occupier::Tenant.connect!("tbs", environment)

Resetting a tenant

    client = Occupier::Mongo::Client.new :development
    Occupier::Tenant.new("tbs", client).reset!

## Databases

You can also access databases directly.

    client = Occupier::Mongo::Client.new :development
    client.database!("FF_development_tbs")

If a database does not exist, the method above will raise an error. If you need access to a database that does not exist, use

    client.database("FF_development_tbs")

## Documentation

Generate documentation for this project using YARD

    yardoc
