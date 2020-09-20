module Occupier
  module Pg

    # @api public
    class Connection
      # extend Forwardable

      attr_reader :environment, :current_database

      # # def_delegator :connection, :database, :database
      # # def_delegator :connection, :drop_database, :drop_database

      def initialize(environment = "development", logger = nil)
        @environment = environment.to_s
        @logger = logger
      end

      def create(database_name)
        config = _config.merge({ dbname: "postgres" })
        conn = PG::Connection.new(config)
        conn.exec("CREATE DATABASE #{database_name}")
        connect(database_name)
      rescue PG::DuplicateDatabase
        false
      end

      # def create!(database_name)
      #   create(database_name) || raise(Occupier::AlreadyExists)
      # end

      def connect(database_name)
        config = _config.merge({ dbname: database_name })
        @connection = PG::Connection.new(config)
      end

      def current_database
        @connection.conninfo_hash[:dbname]
      end

      private

        def _config
          x ||= YAML.load_file("config/pg.yml")
          x[@environment]
        end

    end
  end
end
