describe Occupier::Tenant do
  let(:handle) { Faker::Internet.domain_word }
  let(:client) { Occupier::MongoMapper::Connection.new :test }
  let(:pg_client) { Occupier::Postgres::Client.new :test }

  describe 'initialization' do
    describe 'when no pg client' do
      it 'creates the pg client' do
        tenant = Occupier::Tenant.new(handle, client)
        expect(tenant.instance_variable_get(:@pg_client)).to be_a Occupier::Postgres::Client
      end
    end
  end

  it 'returns a list of handles for all existing tenants' do
    handle_1 = Faker::Internet.domain_word
    handle_2 = Faker::Internet.domain_word

    Occupier::Tenant.new(handle_1, client, pg_client).create!
    Occupier::Tenant.new(handle_2, client, pg_client).create!

    expect(Occupier::Tenant.all(client)).to include handle_1
    expect(Occupier::Tenant.all(client)).to include handle_2
  end

  it 'knows whether a tenant exists' do
    tenant = Occupier::Tenant.new(handle, client, pg_client)

    expect(tenant.exists?).to be false
    tenant.create!

    expect(tenant.exists?).to be true
  end

  context 'all tenants' do
    before do
      Occupier::Tenant.new('one', client, pg_client).create!
      Occupier::Tenant.new('two', client, pg_client).create!
      Occupier::Tenant.new('three', client, pg_client).create!
    end

    it 'returns all tenants' do
      expect(Occupier::Tenant.all(client)).to eq %w[one two three].to_set
    end

    it 'ignores default and common databases' do
      Occupier::Tenant.new('default', client, pg_client).create!
      Occupier::Tenant.new('common', client, pg_client).create!
      Occupier::Tenant.new('four', client, pg_client).create!

      expect(Occupier::Tenant.all(client)).to eq %w[one two three four].to_set
    end
  end

  context 'a tenant' do
    it 'returns its handle' do
      expect(Occupier::Tenant.new(handle, client, pg_client).handle).to eq handle
    end
  end

  context 'creating' do
    context 'an inexistent tenant' do
      it 'creates it' do
        Occupier::Tenant.new(handle, client, pg_client).create!
        expect(Occupier::Tenant.all(client)).to include handle
      end

      it "can't start with a hyphen" do
        expect { Occupier::Tenant.new('-start', client, pg_client) }.to raise_error(Occupier::InvalidTenantName)
      end

      it "can't end with a hyphen" do
        expect { Occupier::Tenant.new('end-', client, pg_client) }.to raise_error(Occupier::InvalidTenantName)
      end

      it "can't start with a number" do
        expect { Occupier::Tenant.new('2go', client, pg_client) }.to raise_error(Occupier::InvalidTenantName)
      end

      it "only creates it if name contains only [a-z\-]" do
        %w[xy tbs thelisbonmba cbs enpc esmt the-school i2i abc123
           this-1s-valid].each do |handle|
          expect(Occupier::Tenant.new(handle, client, pg_client)).to be_a Occupier::Tenant
        end

        ['TBS', 'a b c', 'tbs!', 'go go go', 'ab*c', 'the_school', '-no-good', '2-go', 'a'].each do |handle|
          expect { Occupier::Tenant.new(handle, client, pg_client) }.to raise_error(Occupier::InvalidTenantName)
        end
      end

      it 'is at least 2 characters long' do
        %w[ab abc abcd].each do |handle|
          expect(Occupier::Tenant.new(handle, client, pg_client)).to be_a Occupier::Tenant
        end

        %w[a b].each do |handle|
          expect { Occupier::Tenant.new(handle, client, pg_client) }.to raise_error(Occupier::InvalidTenantName)
        end
      end
    end

    context 'an existing tenant' do
      it 'does not create it' do
        expect(Occupier::Tenant.new(handle, client, pg_client).create!.database).to be_a Mongo::Database
        expect { Occupier::Tenant.new(handle, client, pg_client).create! }.to raise_error(Occupier::AlreadyExists)
      end
    end
  end

  context 'connecting to' do
    context 'an existing tenant' do
      let(:tenant) { Occupier::Tenant.new(handle, client, pg_client).create! }

      it 'connects' do
        expect(Occupier::Tenant.new(tenant.handle, client, pg_client).connect!).to be_a Occupier::Tenant
      end

      context 'short form' do
        it 'connects using the short form' do
          expect(Occupier::Tenant.connect!(tenant.handle, :test)).to be_a Occupier::Tenant
        end
      end
    end

    context 'an inexistent tenant' do
      it 'raises an error' do
        expect { Occupier::Tenant.new(handle, client, pg_client).connect! }.to raise_error(Occupier::NotFound)
      end
    end
  end

  context 'fetching' do
    context 'a database for a non-inexistent tenant' do
      it 'raises an error' do
        expect { Occupier::Tenant.new(handle, client, pg_client).database }.to raise_error(RuntimeError)
      end
    end
  end

  context 'purging' do
    context 'an existing tenant' do
      it 'cleans the database' do
        tenant = Occupier::Tenant.new(handle, client, pg_client)

        tenant.create!
        tenant.database['some_collection'].insert_one({ value: 1 })
        expect(tenant.database['some_collection'].estimated_document_count).to eq 1

        expect(tenant.purge!.database['some_collection'].estimated_document_count).to eq 0
      end
    end
  end

  context 'resetting' do
    context 'an existing tenant' do
      it 'cleans the database' do
        tenant = Occupier::Tenant.new(handle, client, pg_client)

        tenant.create!
        tenant.database['some_collection'].insert_one({ value: 1 })
        expect(tenant.database['some_collection'].estimated_document_count).to eq 1

        expect(tenant.reset!.database['some_collection'].estimated_document_count).to eq 0
      end
    end
  end

  context 'dropping' do
    context 'an existing tenant' do
      it 'drops the database' do
        tenant = Occupier::Tenant.new(handle, client, pg_client)

        tenant.create!
        tenant.database['some_collection'].insert_one({ value: 1 })
        expect(tenant.database['some_collection'].estimated_document_count).to eq 1
        expect(pg_client.database_exists?("FF_test_#{handle}")).to be_truthy

        tenant.drop!
        expect(tenant.exists?).to be false
        expect(pg_client.database_exists?("FF_test_#{handle}")).to be_falsey
      end
    end
  end
end
