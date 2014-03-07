require 'spec_helper'

describe Occupier::Tenant do

  let(:handle)     { Faker::Internet.domain_word }
  let(:connection) { Occupier::MongoMapper::Connection.new :test }

  it "returns a list of handles for all existing tenants" do

    handle_1 = Faker::Internet.domain_word
    handle_2 = Faker::Internet.domain_word

    Occupier::Tenant.new(handle_1, connection).create!
    Occupier::Tenant.new(handle_2, connection).create!

    Occupier::Tenant.all(connection).should include handle_1
    Occupier::Tenant.all(connection).should include handle_2

  end

  it "knows whether a tenant exists" do

    tenant = Occupier::Tenant.new(handle, connection)

    tenant.exists?.should be_false
    tenant.create!

    tenant.exists?.should be_true

  end

  context "a tenant" do

    it "returns its handle" do
      Occupier::Tenant.new(handle, connection).handle.should eq handle
    end

  end




  context "creating" do

    context "an inexistent tenant" do

      it "creates it" do

        Occupier::Tenant.new(handle, connection).create!
        Occupier::Tenant.all(connection).should include handle

      end

      it "only creates it if name contains only [a-z]" do

        [ "tbs", "thelisbonmba", "cbs", "enpc", "esmt"].each do |handle|
          Occupier::Tenant.new(handle, connection).should be_a Occupier::Tenant
        end

        [ "TBS", "the-school", "a b c", "tbs!", "go go go"].each do |handle|
          expect { Occupier::Tenant.new(handle,   connection) }.to raise_error(Occupier::InvalidTenantName)
        end

      end

    end

    context "an existing tenant" do

      it "does not create it" do

        Occupier::Tenant.new(handle, connection).create!.database.should be_a Mongo::DB
        expect { Occupier::Tenant.new(handle, connection).create! }.to raise_error

      end

    end

  end

  context "connecting to" do

    context "an existing tenant" do

      let(:tenant) { Occupier::Tenant.new(handle, connection).create! }

      it "connects" do
        Occupier::Tenant.new(tenant.handle, connection).connect!.should be_a Occupier::Tenant
      end

      it "connects using the short form" do
        Occupier::Tenant.connect!(tenant.handle, :test).should be_a Occupier::Tenant
      end

    end

    context "an inexistent tenant" do

      it "raises an error" do
        expect { Occupier::Tenant.new(handle, connection).connect! }.to raise_error(Occupier::NotFound)
      end

    end

  end

  context "fetching" do

    context "a database for a non-inexistent tenant" do

      it "raises an error" do
        expect { Occupier::Tenant.new(handle, connection).database }.to raise_error
      end

    end

  end

  context "purging" do

    context "an existing tenant" do

      it "cleans the database" do

        tenant = Occupier::Tenant.new(handle, connection)

        tenant.create!
        tenant.database['some_collection'].insert({ value: 1 })
        tenant.database['some_collection'].count.should eq 1

        tenant.purge!.database['some_collection'].count.should eq 0

      end

    end

  end

  context "resetting" do

    context "an existing tenant" do

      it "cleans the database" do

        tenant = Occupier::Tenant.new(handle, connection)

        tenant.create!
        tenant.database['some_collection'].insert({ value: 1 })
        tenant.database['some_collection'].count.should eq 1

        tenant.reset!.database['some_collection'].count.should eq 0

      end

    end

  end

end