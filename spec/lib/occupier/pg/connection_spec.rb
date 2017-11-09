describe Occupier::Pg::Connection do

  it "defaults to development environment" do
    connection = Occupier::Pg::Connection.new
    expect(connection.environment).to eq "development"
  end


  let!(:database_name) { "FF_test_default" }
  let!(:connection) { Occupier::Pg::Connection.new "test" }

  it "creates a database" do
    expect(connection.database_exists?(database_name)).to eq false

    connection.create(database_name)
    expect(connection.database_exists?(database_name)).to eq true
  end

  it "drops database" do
    connection.create(database_name)
    expect(connection.database_exists?(database_name)).to eq true

    connection.drop(database_name)
    expect(connection.database_exists?(database_name)).to eq false
  end

  # it "drops all databases" do
  #   connection.create("FF_test_g")
  #   connection.create("FF_test_h")
  #   connection.create("FF_test_i")
  #   expect(connection.database_names.count).to be > 3
  #   connection.drop_all
  #   expect(connection.database_names.count).to eq 0
  # end

  it "resets database" do
    connection.create(database_name)
    connection.reset(database_name)
    expect(connection.database_exists?(database_name)).to eq(true)
  end

  context "connection to database" do

    it "gets a connection" do
      connection.create(database_name)
      connection.connect(database_name)
      expect(connection.connection).to be_a PG::Connection
    end

    it "closes connection" do
      connection.connect
      connection.close
      expect(connection.connection.finished?).to be true
    end

    it "connects to a database" do
      connection.create(database_name)

      query = connection.connection.exec_params("SELECT current_database()")
      current_database_name = query.first()['current_database']

      expect(current_database_name).to eq database_name.downcase
    end

  end

  it "knows whether a database exists" do
    connection.create(database_name)

    expect(connection.database_exists?("no_db_here")).to eq false
    expect(connection.database_exists?(database_name)).to eq true
  end

  it "gets all FF database names" do
    connection.create(database_name)
    expect(connection.database_names).to include database_name.downcase
  end

end
