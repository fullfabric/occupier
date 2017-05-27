shared_examples_for "client" do

  let (:database_name) { "FF_test_#{Faker::Internet.domain_word}" }
  let (:client) { described_class.new(:test) }

  it "connects to standalone server" do

    # config for standalone server
    config = { "test" => { "host" => "db1", "port" => 27017 } }
    described_class.any_instance.stub(:mongo_config) { config }

    # mock Mongo::Client
    mock_client = double(::Mongo::Client)
    expect(::Mongo::Client).to receive(:new).once.with(["db1:27017"], { logger: nil, w: 1, read: { mode: :primary } }) { mock_client }


    client = described_class.new(:test)
    allow(client).to receive(:database_exists?) { true } # skip creation
    expect(mock_client).to receive(:use).with(database_name) { mock_client }

    # connect
    expect(client.connect!(database_name)).to be true
  end

  it "connects to replica set" do

    # config for standalone server
    config = { "test" => { "hosts" => [ "db1:27017", "db2:27017" ] } }
    described_class.any_instance.stub(:mongo_config) { config }

    # mock Mongo::Client
    mock_client = double(::Mongo::Client)
    expect(::Mongo::Client).to receive(:new).once.with(["db1:27017", "db2:27017"], { logger: nil, w: 1, read: { mode: :primary } }) { mock_client }


    client = described_class.new(:test)
    allow(client).to receive(:database_exists?) { true } # skip creation
    expect(mock_client).to receive(:use).with(database_name) { mock_client }

    # connect
    expect(client.connect!(database_name)).to be true
  end

  it "returns environment" do
    expect(client.environment).to eq "test"
  end

  # it "returns the names of all the existing databases for this environment" do

  #   # client.drop_all
  #   expect(client.database_names).to eq []

  #   client.create(database_name)
  #   expect(client.database_names).to eq [database_name]

  # end

  it "resets tenant" do
    client.connect!(database_name)
    expect(client.reset!).to be_a(described_class)
    expect(client.database_name).to eq database_name
  end

  context "connecting" do

    it "connects" do
      client = described_class.new(:test)
      expect(client.connect!(database_name)).to be true
      expect(client.database_name).to eq database_name
    end

    context "inexistent database" do

      before do
        client.connect!(database_name)
        client.database.drop
      end

      it "creates it" do
        expect(client.connect!(database_name)).to be true
        expect(client.database).to be_a Mongo::Database
        expect(client.database_name).to eq(database_name)
      end

    end

  end

end

describe Occupier::Mongo::Client do
  it_behaves_like "client"
end

# describe Occupier::MongoMapper::Connection do
#   it_behaves_like "client"
# end
