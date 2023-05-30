shared_examples_for "connection" do

  let ( :database_name ) { "FF_test_#{Faker::Internet.domain_word}" }
  let ( :connection )    { described_class.new :test }


  # this test is highlighting how brittle this class is
  # notice we are stubbing class methods and class varibles to
  # be able to test
  # look into separating initialization from building the connection
  it "connects to replica sets" do

    config = {
      "test" => {
        "hosts" => [ "db1", "db2" ]
      }
    }

    expect_any_instance_of(described_class).to receive(:mongo_config) { config }
    expect( Mongo::ReplSetConnection ).to receive( :new ).once.and_return( :mock_class )

    described_class.new :test
  end

  it "makes the environment available" do
    expect( connection.environment ).to eq "test"
  end

  it "returns the names of all the existing databases for this environment" do
    connection.drop_all
    expect( connection.database_names ).to eq []

    connection.create(database_name)
    connection.create("FF_development_otherdb")

    expect( connection.database_names ).to eq [ database_name ]
  end

  it "calls listDatabases with nameOnly: true" do
    mock_database = double(Mongo::DB)

    allow(connection.connection).to receive(:[]).with("admin") { mock_database }
    expect(mock_database).to receive(:command).with({ listDatabases: 1, nameOnly: true }) { { "databases" => [{ "name" => database_name }] } }

    expect( connection.database_names ).to eq [ database_name ]
  end

  it "passes logger to client" do
    logger = double(Object, { debug: true })
    connection = described_class.new(:test, logger)
    expect(connection.connection.logger).to eq(logger)
  end

  context "creating" do

    context "inexistent database" do

      it "creates it" do
        expect( connection.create(database_name)   ).to be_a Mongo::DB
        expect( connection.database(database_name) ).to be_a Mongo::DB
      end

    end
  end

  context "connecting to" do

    context "an existing database" do

      it "connects" do
        connection.create database_name
        expect( connection.connect( database_name ) ).to be true
        expect( connection.current_database ).to eq database_name
      end

    end

  end

  context "getting an" do

    context "existing database" do

      it "returns the database" do
        connection.create database_name
        expect( connection.database database_name ).to be_a Mongo::DB
      end

    end

    context "inexisting database" do

      it "raises an error" do
        expect{ connection.database!(database_name) }.to raise_error(RuntimeError)
      end

      it "forces database creation" do
        expect(connection.database(database_name)).to be_a(Mongo::DB)
      end

    end

  end

end

describe Occupier::Mongo::Connection do
  it_behaves_like "connection"
end

describe Occupier::MongoMapper::Connection do
  it_behaves_like "connection"
end
