require 'active_record/connection_adapters/postgresql_adapter'

module CustomPostgreSQLAdapter
  # Allows us to connect to a new database in a clean way
  def change_database!(db)
    return if @config[:database] == db
    @config = @config.merge(database: db)

    clear_query_cache
    reconnect!
  end

  def restore_default_database!
    database = YAML.load_file('config/database.yml')[Rails.env]['database']
    change_database!(database)
  end
end

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(CustomPostgreSQLAdapter)
