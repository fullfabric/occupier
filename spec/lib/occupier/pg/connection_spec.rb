describe Occupier::Pg::Connection do

  before :all do
    connection = Occupier::Pg::Connection.new
    connection.drop_all
    connection.create("FF_development_default")
  end

  let!(:database_name) { "FF_development_default" }
  let!(:connection) { Occupier::Pg::Connection.new }

  it "defaults to development environment" do
    expect(connection.environment).to eq "development"
  end

  it "creates a database" do
    database_name = "FF_development_a"

    connection.drop(database_name) if connection.database_exists?(database_name)
    expect(connection.database_exists?(database_name)).to eq false

    connection.create(database_name)
    expect(connection.database_exists?(database_name)).to eq true
  end

  it "drops database" do
    database_name = "FF_development_b"

    connection.connection.exec("CREATE DATABASE #{database_name}")
    expect(connection.database_exists?(database_name)).to eq true

    connection.drop(database_name)
    expect(connection.database_exists?(database_name)).to eq false
  end

  # it "drops all databases" do
  #   connection.create("FF_development_g")
  #   connection.create("FF_development_h")
  #   connection.create("FF_development_i")
  #   expect(connection.database_names.count).to be > 3
  #   connection.drop_all
  #   expect(connection.database_names.count).to eq 0
  # end

  it "resets database" do
    database_name = "FF_development_c"
    connection.create(database_name)
    connection.reset(database_name)
    expect(connection.database_exists?(database_name)).to eq(true)
  end

  context "connection to database" do

    let!(:db) { connection.connection }

    it "gets a connection" do
      expect(db).to be_a PG::Connection
    end

    it "closes connection" do
      connection.close
      expect(db.finished?).to be true
    end

    it "connects to a database" do
      connection.connect(database_name)

      query = connection.connection.exec_params("SELECT current_database()")
      current_database_name = query.first()['current_database']

      expect(current_database_name).to eq database_name.downcase
    end

  end

  it "knows whether a database exists" do
    expect(connection.database_exists?("no_db_here")).to eq false
    expect(connection.database_exists?("postgres")).to eq true
  end

  it "gets all FF database names" do
    expect(connection.database_names).to include database_name.downcase
  end

end
