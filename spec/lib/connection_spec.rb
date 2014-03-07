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
    ::Mongo::ReplSetConnection.should_receive( :new ).once.and_return( :mock_class )

    described_class.new :test

  end

  it "should make the environment available" do
    connection.environment.should eq "test"
  end

  it "should return the names of all the existing databases for this environment" do

    connection.drop_all
    connection.database_names.should eq []

    connection.create(database_name)
    connection.database_names.should eq [ database_name ]

  end

  context "creating" do

    context "inexistent database" do

      it "should create it" do

        connection.create(database_name).should   be_a Mongo::DB
        connection.database(database_name).should be_a Mongo::DB

      end

    end
  end

  context "connecting to" do

    context "an existing database" do

      it "should connect" do
        connection.create database_name
        connection.connect(database_name).should be_true
        connection.current_database.should eq database_name
      end

    end

  end

  context "getting an" do

    context "existing database" do

      it "should return the database" do

        connection.create database_name

        connection.database(database_name).should be_a Mongo::DB

      end

    end

    context "inexisting database" do

      it "should raise an error" do
        -> { connection.database(database_name) }.should raise_error
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