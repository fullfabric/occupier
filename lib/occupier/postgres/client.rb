# frozen_string_literal: true

module Occupier
  module Postgres
    # @api public
    class Client
      extend Forwardable

      CantConnectToPGDatabase = Class.new(StandardError)

      attr_reader :environment

      def initialize(environment = 'development', logger = nil)
        @environment = environment.to_s
        @logger = logger
        @connected = false
      end

      def create(database_name)
        if database_exists? database_name
          raise ::Occupier::AlreadyExists.new("database #{database_name} already exists in environment #{@environment} on Postgres")
        end

        connect.execute("CREATE DATABASE \"#{database_name}\"")
      end

      def close
        ActiveRecord::Base.connection.disconnect!
      end

      def connect(database_name = nil)
        connect_to(database_name)

        ActiveRecord::Base.connection
      rescue StandardError => e
        raise CantConnectToPGDatabase, "Could not connect to database: #{e.message}"
      end

      def reset(database_name)
        drop_database(database_name)
        create(database_name)
        self
      end

      def database_names
        connect.execute("SELECT datname FROM pg_database WHERE datname ILIKE 'FF_#{@environment}_%'").values.flatten
      end

      def database_exists?(database_name)
        connect.execute("SELECT 1 FROM pg_database WHERE datname = '#{database_name}'").ntuples.positive?
      end

      def drop_database(database_name)
        connect.execute("DROP DATABASE IF EXISTS \"#{database_name}\" WITH (FORCE)")
      end

      def drop_all
        database_names.each { |name| drop_database(name) }
      end

      private

      # Connects to the database
      # when no database name is provided uses the database from the configuration
      def connect_to(database_name)
        establish_initial_connection unless @connected

        ActiveRecord::Base.connection.change_database!(database_name)
      end

      def db_config
        @db_config ||= begin
          config = File.read('config/database.yml')
          template = ERB.new(config).result
          database_yml = YAML.safe_load(template, aliases: true)
          database_yml[@environment]
        end
      end

      def establish_initial_connection
        ActiveRecord::Base.establish_connection(db_config)
        @connected = true
      end
    end
  end
end
