shared_examples_for "client" do

  let (:database_name) { "FF_test_#{Faker::Internet.domain_word}" }
  let (:client)        { described_class.new :test }

  # this test is highlighting how brittle this class is
  # notice we are stubbing class methods and class varibles to
  # be able to test
  # look into separating initialization from building the client
  it "connects to replica sets" do
    config = {
      "test" => {
        "hosts" => [ "db1", "db2" ]
      }
    }

    expect_any_instance_of(described_class).to receive(:mongo_config) { config }
    expect(Mongo::Client).to receive(:new).once.and_return(:mock_class)

    described_class.new :test
  end

  it "makes the environment available" do
    expect(client.environment).to eq "test"
  end

  it "returns the names of all the existing databases for this environment" do
    client.drop_all
    expect(client.database_names).to eq []

    client.create(database_name)
    client.create("FF_development_otherdb")
    expect(client.database_names).to eq [database_name]
  end

  it "calls listDatabases with nameOnly: true" do
    mock_admin_client = double(Mongo::Client)
    mock_database = double(Mongo::Database)
    mock_result = double(Mongo::Operation::Result)

    allow(client.client).to receive(:use).with("admin") { mock_admin_client }
    allow(mock_admin_client).to receive(:database) { mock_database }
    allow(mock_result).to receive(:documents) { [{ "databases" => [{ "name" => database_name }] }] }
    expect(mock_database).to receive(:command).with({ listDatabases: 1, nameOnly: true }) { mock_result }

    expect(client.database_names).to eq [database_name]
  end

  it "passes logger to client" do
    logger = double(Object, { debug?: true, debug: true })
    client = described_class.new(:test, logger)
    expect(client.client.logger).to eq(logger)
  end

  context "creating" do
    context "inexistent database" do
      it "creates it" do
        expect(client.create(database_name)  ).to be_a Mongo::Database
        expect(client.database(database_name)).to be_a Mongo::Database
      end
    end
  end

  context "getting an" do
    context "existing database" do
      it "returns the database" do
        client.create database_name
        expect(client.database database_name).to be_a Mongo::Database
      end
    end

    context "inexisting database" do
      it "raises an error" do
        expect { client.database!(database_name) }.to raise_error(RuntimeError)
      end

      it "forces database creation" do
        expect(client.database(database_name)).to be_a(Mongo::Database)
      end
    end
  end

  describe "#close" do
    it "closes the underlying connection" do
      expect(client.client).to receive(:close)
      client.close
    end

    it "closes all clients created for databases" do
      database_name_2 = "FF_test_#{Faker::Internet.domain_word}"
      db_1 = client.create database_name
      db_2 = client.create database_name_2

      expect(client.send(:db_client, database_name)).to receive(:close)
      expect(client.send(:db_client, database_name_2)).to receive(:close)
      client.close
    end
  end
end

describe Occupier::Mongo::Client do
  it_behaves_like "client"
end

describe Occupier::MongoMapper::Connection do
  it_behaves_like "client"

  let (:client) { described_class.new :test }

  context "connecting to" do
    context "an existing database" do
      it "connects" do
        database_name = "FF_test_#{Faker::Internet.domain_word}"

        client.create database_name

        expect(client.connect(database_name)).to be true
        expect(client.current_database).to eq database_name
      end
    end
  end
end
