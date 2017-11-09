describe Occupier::Tenant do

  let(:handle)     { Faker::Internet.domain_word }
  let(:connection_mongo) { Occupier::MongoMapper::Connection.new :test }
  let(:connection_pg) { Occupier::Pg::Connection.new :test }


  it "returns a list of handles for all existing tenants" do

    handle_1 = Faker::Internet.domain_word
    handle_2 = Faker::Internet.domain_word

    Occupier::Tenant.new(handle_1, connection_mongo).create!
    Occupier::Tenant.new(handle_2, connection_mongo).create!

    expect(Occupier::Tenant.all(connection_mongo)).to include handle_1
    expect(Occupier::Tenant.all(connection_mongo)).to include handle_2

  end

  it "knows whether a tenant exists" do

    tenant = Occupier::Tenant.new(handle, connection_mongo)

    expect( tenant.exists? ).to be false
    tenant.create!

    expect( tenant.exists? ).to be true

  end

  context "a tenant" do

    it "returns its handle" do
      expect( Occupier::Tenant.new(handle, connection_mongo).handle ).to eq handle
    end

  end

  context "creating" do

    context "an inexistent tenant" do

      it "creates it" do

        tenant = Occupier::Tenant.new(handle, connection_mongo, connection_pg)
        tenant.create!

        expect(Occupier::Tenant.all(connection_mongo)).to include handle
        expect(connection_pg.database_exists?(tenant.database_name)).to eq(true)

      end

      it "only creates it if name contains only [a-z]" do

        [ "tbs", "thelisbonmba", "cbs", "enpc", "esmt"].each do |handle|
          expect(Occupier::Tenant.new(handle, connection_mongo)).to be_a Occupier::Tenant
        end

        [ "TBS", "the-school", "a b c", "tbs!", "go go go"].each do |handle|
          expect { Occupier::Tenant.new(handle,   connection_mongo) }.to raise_error(Occupier::InvalidTenantName)
        end

      end

    end

    context "an existing tenant" do

      it "does not create it" do

        Occupier::Tenant.new(handle, connection_mongo).create!.database.should be_a Mongo::DB
        expect { Occupier::Tenant.new(handle, connection_mongo).create! }.to raise_error

      end

    end

  end

  context "connecting to" do

    context "an existing tenant" do

      let!(:tenant) { Occupier::Tenant.new(handle, connection_mongo).create! }

      it "connects" do
        expect(Occupier::Tenant.new(handle, connection_mongo).connect!).to be_a Occupier::Tenant
      end

      context "short form" do

        it "connects using the short form" do
          expect(Occupier::Tenant.connect!(tenant.handle, :test)).to be_a Occupier::Tenant
        end

        it "does not connect to postgres" do
          expect(Occupier::Tenant).to receive(:new).with { |arg1, arg2, arg3|
            expect(arg1).to eq tenant.handle
            expect(arg3).to be_nil
          } { double(Occupier::Tenant, connect!: true ) }
          Occupier::Tenant.connect!(tenant.handle, :test)
        end

      end

      context "inexistent postgres database" do

        it "connects to mongo" do
          expect(Occupier::Tenant.connect!(tenant.handle, :test)).to be_a Occupier::Tenant
          expect(connection_mongo.current_database).to eq tenant.database_name
        end

      end

    end

    context "an inexistent tenant" do

      it "raises an error" do
        expect { Occupier::Tenant.new(handle, connection_mongo).connect! }.to raise_error(Occupier::NotFound)
      end

    end

  end

  context "fetching" do

    context "a database for a non-inexistent tenant" do

      it "raises an error" do
        expect { Occupier::Tenant.new(handle, connection_mongo).database }.to raise_error
      end

    end

  end

  context "purging" do

    context "an existing tenant" do

      it "cleans the database" do

        tenant = Occupier::Tenant.new(handle, connection_mongo)

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

        tenant = Occupier::Tenant.new(handle, connection_mongo)

        tenant.create!
        tenant.database['some_collection'].insert({ value: 1 })
        tenant.database['some_collection'].count.should eq 1

        tenant.reset!.database['some_collection'].count.should eq 0

      end

    end

  end

end
