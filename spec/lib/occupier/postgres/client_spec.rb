RSpec.describe Occupier::Postgres::Client do
  let(:environment) { 'test' }
  let(:client) { described_class.new(environment, nil) }
  let(:database_name) { 'FF_test_fullfabric' }

  describe '#initialize' do
    it 'sets the environment' do
      expect(client.environment).to eq(environment)
    end
  end

  describe '#create' do
    it 'creates a new database' do
      expect(client.database_exists?(database_name)).to be_falsey
      client.create(database_name)
      expect(client.database_exists?(database_name)).to be_truthy
    end

    it 'raises an error if the database already exists' do
      client.create(database_name)
      expect { client.create(database_name) }.to raise_error(RuntimeError, 'database already exists')
    end
  end

  describe '#close' do
    it 'closes the connection' do
      expect(ActiveRecord::Base.connection.active?).to be_truthy
      client.close
      expect(ActiveRecord::Base.connection.active?).to be_falsey
    end
  end

  describe '#connect' do
    before do
      client.create('FF_test_default')
      client.create(database_name)
    end

    it 'connects to the specified database' do
      client.connect('FF_test_default')
      expect(ActiveRecord::Base.connection.current_database).to eq('FF_test_default')
      expect(ActiveRecord::Base.connection.execute('SELECT CURRENT_DATABASE()').to_a).to eq([{"current_database"=>"FF_test_default"}])
      client.connect(database_name)
      expect(ActiveRecord::Base.connection.current_database).to eq(database_name)
      expect(ActiveRecord::Base.connection.execute('SELECT CURRENT_DATABASE()').to_a).to eq([{"current_database"=>database_name}])
    end

    it 'do not gives an raise' do
      expect { client.connect(database_name) }.not_to raise_error
    end

    it 'raises an error if connection fails' do
      allow(ActiveRecord::Base.connection).to receive(:change_database!).and_raise(StandardError.new('error'))

      expect do
        client.connect('random_db')
      end.to raise_error(Occupier::Postgres::Client::CantConnectToPGDatabase, /Could not connect to database:/)
    end

    describe 'performance' do
      describe 'when the database is the same as the connected one' do
        it 'connection is under 1ms for the same db' do
          client.connect(database_name) # warm up

          avg = Benchmark.ms do
            2.times { client.connect(database_name) }
          end / 2
          # normally it should be under 1ms, but we are adding some margin
          expect(avg).to be < 1
        end
      end

      describe 'when the database is the same as the connected one' do
        let(:times) { 10 }
        before do
          (1..times).each { |i| client.create("#{database_name}#{i}") }
        end

        it 'connection is under 5ms for a different db' do
          avg = Benchmark.ms do
            (1..times).each { |i| client.connect("#{database_name}#{i}") }
          end / times
          # normally it should be under 5ms, but we are adding some margin
          expect(avg).to be < 10
        end
      end
    end
  end

  describe '#reset' do
    it 'resets the database' do
      expect(client.database_exists?(database_name)).to be_falsey
      client.create(database_name)
      expect(client.database_exists?(database_name)).to be_truthy

      expect(client).to receive(:drop_database).with(database_name).and_call_original
      client.reset(database_name)
      expect(client.database_exists?(database_name)).to be_truthy
    end
  end

  describe '#database_names' do
    before do
      client.drop_database('random_db')
      client.create('random_db')
    end

    it 'returns an array of database names' do
      expect(client.database_names).to be_empty
      client.create(database_name)
      expect(client.database_names).to eql([database_name])
    end
  end

  describe '#database_exists?' do
    it 'returns_truthy if the database exists' do
      client.create(database_name)
      expect(client.database_exists?(database_name)).to be_truthy
    end

    it 'returns false if the database does not exist' do
      expect(client.database_exists?(database_name)).to be_falsey
    end
  end

  describe '#drop_database' do
    it 'drops the specified database' do
      allow(client).to receive_message_chain(:client, :execute).with("DROP DATABASE IF EXISTS #{database_name}")
      expect { client.drop_database(database_name) }.not_to raise_error
    end
  end

  describe '#drop_all' do
    before do
      client.drop_database('random_db')
      1..10.times { |i| client.create("#{database_name}#{i}") }
      client.create('random_db')
    end

    it 'drops all databases matching the environment pattern' do
      expect { client.drop_all }.not_to raise_error
      expect(client.database_names).to be_empty

      expect(client.database_exists?('random_db')).to be_truthy
      1..10.times { |i| expect(client.database_exists?("#{database_name}#{i}")).to be_falsey }
    end
  end
end
