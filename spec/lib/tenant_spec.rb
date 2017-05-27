describe Occupier::Tenant do

  let(:handle)     { Faker::Internet.domain_word }
  let(:client) { Occupier::Mongo::Client.new :test }

  it "allows handes with lowercase alpha characters" do
    expect(Occupier::Tenant.new("abc", client)).to be_a Occupier::Tenant
  end

  it "does not allow handes with other characters" do
    expect{ Occupier::Tenant.new("abc1", client) }.to raise_error(Occupier::InvalidTenantName)
  end

  it "returns a list of handles for all existing tenants" do
    handle_1 = Faker::Internet.domain_word
    handle_2 = Faker::Internet.domain_word

    Occupier::Tenant.new(handle_1, client).create!
    Occupier::Tenant.new(handle_2, client).create!

    expect(Occupier::Tenant.all(client)).to include handle_1
    expect(Occupier::Tenant.all(client)).to include handle_2
  end

  it "knows whether a tenant exists" do

    tenant = Occupier::Tenant.new(handle, client)

    expect(tenant.exists?).to be false
    tenant.create!

    expect(tenant.exists?).to be true

  end

  context "a tenant" do

    before do
      Occupier::Tenant.new(handle, client).create!
    end

    it "connects" do
      tenant = Occupier::Tenant.new(handle, client)
      expect(tenant.connect!).to be_a(Occupier::Tenant)
      expect(tenant.database).to be_a(Mongo::Database)
    end

    it "returns its handle" do
      expect( Occupier::Tenant.connect!(handle, :test).handle ).to eq handle
    end

  end

  context "creating" do

    context "an inexistent tenant" do

      it "creates it" do
        Occupier::Tenant.new(handle, client).create!
        expect(Occupier::Tenant.all(client)).to include handle
      end

      it "only creates it if name contains only [a-z]" do

        [ "tbs", "thelisbonmba", "cbs", "enpc", "esmt"].each do |handle|
          Occupier::Tenant.new(handle, client).should be_a Occupier::Tenant
        end

        [ "TBS", "the-school", "a b c", "tbs!", "go go go"].each do |handle|
          expect { Occupier::Tenant.new(handle,   client) }.to raise_error(Occupier::InvalidTenantName)
        end

      end

    end

    context "an existing tenant" do

      it "does not create it" do
        tenant = Occupier::Tenant.new(handle, client).create!
        expect(tenant.database).to be_a Mongo::Database

        expect { Occupier::Tenant.new(handle, client).create! }.to raise_error
      end

    end

  end

  context "connecting to" do

    context "an existing tenant" do

      let(:tenant) { Occupier::Tenant.new(handle, client).create! }

      it "connects" do
        Occupier::Tenant.new(tenant.handle, client).connect!.should be_a Occupier::Tenant
      end

      it "connects using the short form" do
        Occupier::Tenant.connect!(tenant.handle, :test).should be_a Occupier::Tenant
      end

    end

    context "an inexistent tenant" do

      it "raises an error" do
        expect { Occupier::Tenant.new(handle, client).connect! }.to raise_error(Occupier::NotFound)
      end

    end

  end

  context "resetting" do

    context "an existing tenant" do

      it "cleans the database" do

        tenant = Occupier::Tenant.new(handle, client)
        tenant.create!

        tenant.collection('some_collection').insert_one({ value: 1 })
        tenant.collection('some_collection').count.should eq 1

        tenant.reset!
        tenant.collection('some_collection').count.should eq 0

      end

    end

  end

end
