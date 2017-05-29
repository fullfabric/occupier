# Occupier

Connect to different tenant databases in Mongo.

## Requirements

MongoDB 3.0+

## Usage

Creating a new tenant
    
    client = Occupier::Mongo::Client.new(:development)
    Occupier::Tenant.new("tbs", client).create!

Connecting to an existing tenant
    
    client = Occupier::Mongo::Client.new(:development)
    Occupier::Tenant.new("tbs", client).connect!

Connecting to an existing tenant using the short form

    Occupier::Tenant.connect!("tbs", environment)

Resetting a tenant
    
    client = Occupier::Mongo::Client.new(:development)
    Occupier::Tenant.new("tbs", client).reset!

Generate documentation for this project using YARD

## Middleware

Occupier provides two different middlewares, allowing your rack application to extract the tenant from either the host name or via the request

### HostMiddleware

### RequestMiddleware
    
    yardoc
