describe Occupier::Tenant do

  let(:handle)     { Faker::Internet.domain_word }
  let(:connection) { Occupier::MongoMapper::Connection.new :test }

  it "returns a list of handles for all existing tenants" do
    handle_1 = Faker::Internet.domain_word
    handle_2 = Faker::Internet.domain_word

    Occupier::Tenant.new(handle_1, connection).create!
    Occupier::Tenant.new(handle_2, connection).create!

    expect(Occupier::Tenant.all(connection)).to include handle_1
    expect(Occupier::Tenant.all(connection)).to include handle_2
  end

  it "knows whether a tenant exists" do
    tenant = Occupier::Tenant.new(handle, connection)

    expect(tenant.exists?).to be false
    tenant.create!

    expect(tenant.exists?).to be true
  end

  context "all tenants" do

    before do
      Occupier::Tenant.new("one", connection).create!
      Occupier::Tenant.new("two", connection).create!
      Occupier::Tenant.new("three", connection).create!
    end

    it "returns all tenants" do
      expect(Occupier::Tenant.all(connection)).to eq ["one", "two", "three"].to_set
    end

    it "ignores default and common databases" do
      Occupier::Tenant.new("default", connection).create!
      Occupier::Tenant.new("common", connection).create!
      Occupier::Tenant.new("four", connection).create!

      expect(Occupier::Tenant.all(connection)).to eq ["one", "two", "three", "four"].to_set
    end

  end

  context "a tenant" do

    it "returns its handle" do
      expect( Occupier::Tenant.new(handle, connection).handle ).to eq handle
    end

  end

  context "creating" do

    context "an inexistent tenant" do

      it "creates it" do
        Occupier::Tenant.new(handle, connection).create!
        expect(Occupier::Tenant.all(connection)).to include handle
      end

      it "can't start with a hyphen" do
        expect { Occupier::Tenant.new("-start", connection) }.to raise_error(Occupier::InvalidTenantName)
      end

      it "can't end with a hyphen" do
        expect { Occupier::Tenant.new("end-", connection) }.to raise_error(Occupier::InvalidTenantName)
      end

      it "can't start with a number" do
        expect { Occupier::Tenant.new("2go", connection) }.to raise_error(Occupier::InvalidTenantName)
      end

      it "only creates it if name contains only [a-z\-]" do

        [ "tbs", "thelisbonmba", "cbs", "enpc", "esmt", "the-school", "i2i", "abc123", "this-1s-valid"].each do |handle|
          expect(Occupier::Tenant.new(handle, connection)).to be_a Occupier::Tenant
        end

        [ "TBS", "a b c", "tbs!", "go go go", "ab*c", "the_school", "-no-good", "2-go", "a", "ab"].each do |handle|
          expect { Occupier::Tenant.new(handle,   connection) }.to raise_error(Occupier::InvalidTenantName)
        end

      end

      it "is at least 3 characters long" do

        [ "abc", "abcd" ].each do |handle|
          expect(Occupier::Tenant.new(handle, connection)).to be_a Occupier::Tenant
        end

        ["a", "ab"].each do |handle|
          expect { Occupier::Tenant.new(handle,   connection) }.to raise_error(Occupier::InvalidTenantName)
        end

      end

    end

    context "an existing tenant" do

      it "does not create it" do
        expect(Occupier::Tenant.new(handle, connection).create!.database).to be_a Mongo::DB
        expect { Occupier::Tenant.new(handle, connection).create! }.to raise_error(Occupier::AlreadyExists)
      end

    end

  end

  context "connecting to" do

    context "an existing tenant" do

      let(:tenant) { Occupier::Tenant.new(handle, connection).create! }

      it "connects" do
        expect(Occupier::Tenant.new(tenant.handle, connection).connect!).to be_a Occupier::Tenant
      end

      context "short form" do

        it "connects using the short form" do
          expect(Occupier::Tenant.connect!(tenant.handle, :test)).to be_a Occupier::Tenant
        end

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
        expect { Occupier::Tenant.new(handle, connection).database }.to raise_error(RuntimeError)
      end

    end

  end

  context "purging" do

    context "an existing tenant" do

      it "cleans the database" do

        tenant = Occupier::Tenant.new(handle, connection)

        tenant.create!
        tenant.database['some_collection'].insert({ value: 1 })
        expect(tenant.database['some_collection'].count).to eq 1

        expect(tenant.purge!.database['some_collection'].count).to eq 0
      end

    end

  end

  context "resetting" do

    context "an existing tenant" do

      it "cleans the database" do

        tenant = Occupier::Tenant.new(handle, connection)

        tenant.create!
        tenant.database['some_collection'].insert({ value: 1 })
        expect(tenant.database['some_collection'].count).to eq 1

        expect(tenant.reset!.database['some_collection'].count).to eq 0
      end

    end

  end

end
