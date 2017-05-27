module Occupier
  module Mongo

    # @api public
    class Client

      attr_reader :environment

      def initialize(environment = "development", logger = nil)
        @environment = environment.to_s
      end

      def connected?
        !!@client
      end

      def connect!(database_name)
        @client = client.use(database_name)
        create! unless database_exists?(database_name)
        true
      end

      def collection(name)
        client[name] if connected?
      end

      def close
        client.close if connected?
      end

      def database
        if connected?
          raise "database does not exist" unless database_exists?(client.database.name)
          client.database
        end
      end

      def database_name
        client.database.name if connected?
      end

      def reset!
        database.drop and create!
        self
      end

      def database_exists?(database_name)
        client.database_names.one? { |name| name == database_name }
      end

      def database_names
        client.database_names.select { |name| name =~ /^FF_#{@environment}_/ }
      end

      # def drop_all
      #   database_names.each { |name| client.use(name).database.drop }
      # end

      private

        def client
          @client ||= begin
            config = mongo_config[@environment]

            options            = { logger: nil }
            options[:w]        = config.fetch('write', 1).to_i
            options[:read]     = { mode: config.fetch('read', :primary).to_sym }
            # options[:database] = database_name

            hosts = config['hosts'] || ["#{config['host']}:#{config['port']}"]

            ::Mongo::Client.new(hosts, options)
          end
        end

        def create!
          client["_dummy" ].create
        end

        def mongo_config
          @@mongo_config ||= begin
            mongo_config = File.read( 'config/mongo.yml' ) { |f| f.read }
            template     = ERB.new( mongo_config ).result

            YAML.load(template)
          end
        end

    end
  end
end
