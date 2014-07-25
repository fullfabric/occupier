require 'spec_helper'

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

    described_class.any_instance.stub( :mongo_config ).and_return( config )
    expect( Mongo::ReplSetConnection ).to receive( :new ).once.and_return( :mock_class )

    described_class.new :test

  end

  it "should make the environment available" do
    expect( connection.environment ).to eq "test"
  end

  it "should return the names of all the existing databases for this environment" do

    connection.drop_all
    expect( connection.database_names ).to eq []

    connection.create(database_name)
    expect( connection.database_names ).to eq [ database_name ]

  end

  context "creating" do

    context "inexistent database" do

      it "should create it" do

        expect( connection.create(database_name)   ).to be_a Mongo::DB
        expect( connection.database(database_name) ).to be_a Mongo::DB

      end

    end
  end

  context "connecting to" do

    context "an existing database" do

      it "should connect" do
        connection.create database_name
        expect( connection.connect( database_name ) ).to be_truthy
        expect( connection.current_database ).to eq database_name
      end

    end

  end

  context "getting an" do

    context "existing database" do

      it "should return the database" do

        connection.create database_name
        expect( connection.database database_name ).to be_a Mongo::DB

      end

    end

    context "inexisting database" do

      it "should raise an error" do
        expect{ connection.database database_name }.to raise_error
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
