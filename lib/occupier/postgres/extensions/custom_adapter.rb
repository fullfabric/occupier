require 'active_record/connection_adapters/postgresql_adapter'

module CustomPostgreSQLAdapter
  # Allows us to connect to a new database in a clean way
  def change_database!(db)
    pg_config = @connection.instance_variable_get('@iopts_for_reset')
    return if pg_config[:dbname] == db

      # This is a hack to allow us to change the database name
      # without having to create a "new" connection
      pg_config.merge!(dbname: db)
      clear_cache!
      @connection.reset
  end

  def restore_default_database!
    database = YAML.load_file('config/database.yml')[Rails.env]['database']
    change_database!(database)
  end
end

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(CustomPostgreSQLAdapter)
