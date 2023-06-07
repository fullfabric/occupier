module Occupier

  module Mongo

    # @api public
    class Client

      extend Forwardable

      attr_reader :environment

      def initialize environment = "development", logger = nil
        @environment = environment.to_s
        @logger = logger
        @db_clients = {}

        client
      end

      def client
        @client ||= begin

          config = mongo_config[@environment]

          options         =  { logger: @logger }
          options[:write] =  { w: config['write'].try(:to_i) || 1 }
          options[:read]  =  { mode: config['read'].try(:to_sym) || :primary }

          addresses = config['hosts'] || ["#{config['host']}:#{config['port']}"]

          ::Mongo::Client.new(addresses, options)

        end
      end

      def create database_name
        raise "database already exists" if database_exists? database_name
        db = db_client(database_name).database
        db["_dummy"].insert_one({})
        db
      end

      def close
        @db_clients.each { |_name, client| client.close }
        client.close
      end

      def database database_name
        db_client(database_name).database
      end

      def database! database_name
        raise "database does not exist" unless database_exists? database_name
        db_client(database_name).database
      end

      def reset database_name
        drop_database database_name
        create database_name
        self
      end

      def database_exists? database_name
        database_names.one? { |name| name == database_name }
      end

      def database_names
        # TODO: test changing this to `client.database_names`

        # XXX: this is filtering by the DB prefix, but we're not actually
        # enforcing the prefix on database creation. There's no guarantee that
        # all the databases that are created via the client will be returned
        # here.

        result = db_client("admin").database.command({ listDatabases: 1, nameOnly: true })
        result.documents.first["databases"]
          .map { |h| h["name"] }
          .select { |name| name =~ /^FF_#{@environment}_/ }
      end

      def drop_database database_name
        db_client(database_name).database.drop
      end

      def drop_all
        database_names.each { |name| drop_database name }
      end

      private

        def mongo_config
          @@mongo_config ||= begin

            mongo_config = File.read('config/mongo.yml') { |f| f.read }
            template     = ERB.new(mongo_config).result

            YAML.load template

          end
        end

        def db_client database_name
          @db_clients[database_name] ||= client.use(database_name)
        end

    end
  end
end
