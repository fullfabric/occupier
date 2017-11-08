module Occupier

  module Pg

    # @api public
    class Connection

      extend Forwardable

      attr_reader :connection, :environment, :current_database

      def_delegator :connection, :database, :database
      def_delegator :connection, :drop_database, :drop_database

      def initialize environment = "development", logger = nil
        @environment = environment.to_s
        connect
      end

      def create database_name
        raise "database already exists" if database_exists?(database_name)
        connect("postgres")
        connection.exec("CREATE DATABASE #{database_name}")
        connect(database_name)
      end

      def drop database_name
        connect("postgres")
        connection.exec("SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='#{database_name.downcase}'")
        connection.exec("DROP DATABASE IF EXISTS #{database_name}")
      end

      def connect database_name = 'postgres'
        @connection = ::PG::Connection.new(config_file[@environment].merge({ dbname: database_name.downcase }))
        ::ActiveRecord::Base.establish_connection(config_file[@environment].merge({ adapter: "postgresql", database: database_name.downcase }))
        true
      end

      def close
        @connection.close
      end

      def reset database_name
        connect(database_name)
        drop(database_name)
        create(database_name)
        self
      end

      def database_exists? database_name
        connect
        connection.exec_params("SELECT 1 FROM pg_database WHERE datname='#{database_name.downcase}'").count > 0
        # database_names.one? { |name| name == database_name }
      end

      def database_names
        connect
        connection.exec("SELECT datname FROM pg_database WHERE datname ILIKE 'FF_#{@environment}_%'").to_a.map { |h| h['datname'] }
      end

      def drop_all
        connect
        database_names.each { |name| drop(name) }
      end

      private

        def config_file

          @@config_file ||= begin

            config = File.read('config/pg.yml') { |f| f.read }
            template = ERB.new(config).result

            YAML.load(template)

          end
        end

    end
  end
end
