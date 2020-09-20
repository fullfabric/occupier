describe Occupier::Pg::Connection do

  let (:database_name) { "test_#{Faker::Internet.domain_word}" }
  let (:connection)    { described_class.new(:test) }


  it "takes the environment and casts it to a string" do
    expect(connection.environment).to eq "test"
  end

  it "connects to database" do
    expect(connection.connect("postgres")).to be_a(PG::Connection)
  end

  # it "returns the names of all the existing databases for this environment" do
  #   connection.drop_all
  #   expect( connection.database_names ).to eq []

  #   connection.create(database_name)
  #   expect( connection.database_names ).to eq [ database_name ]
  # end

  # it "passes logger to client" do
  #   logger = double(Object, { debug: true })
  #   connection = described_class.new(:test, logger)
  #   expect(connection.connection.logger).to eq(logger)
  # end

  context "creating" do

    context "inexistent database" do

      it "creates it" do
        expect(connection.create(database_name)).to be_a PG::Connection
      end

    end

  end

  context "connecting to" do

    context "an existing database" do

      before do
        connection.create(database_name)
      end

      it "connects" do
        pg_conn = connection.connect(database_name)
        expect(pg_conn).to be_a(PG::Connection)
        expect(connection.current_database).to eq database_name
      end

    end

  end

end
