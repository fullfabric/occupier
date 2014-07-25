module Occupier

  module Mongo

    # @api public
    class Connection

      extend Forwardable

      attr_reader :environment, :current_database

      def_delegator :connection, :database, :database
      def_delegator :connection, :drop_database, :drop_database

      def initialize environment = "development", logger = nil
        @environment = environment.to_s
        connection
      end

      def connection

        @connection ||= begin

          config = mongo_config[ @environment ]

          options          = { logger: nil }
          options[ :w ]    = config[ 'write' ].try( :to_i )  || 1
          options[ :read ] = config[ 'read' ].try( :to_sym ) || :primary

          if config[ 'hosts' ]
            ::Mongo::ReplSetConnection.new( config[ 'hosts' ], options )
          else
            ::Mongo::MongoClient.new( config[ 'host' ], config[ 'port' ], options )
          end

        end

      end

      def create database_name
        raise "database already exists" if database_exists? database_name
        connection[ database_name ].collection("_dummy").insert({})
        connection[ database_name ]
      end

      def connect database_name
        @current_database = database_name
        true
      end

      def close
        connection.close
      end

      def database database_name
        raise "database does not exist" unless database_exists? database_name
        connection[ database_name ]
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
        connection.database_names.select { |name| name =~ /^FF_#{@environment}_/ }
      end

      def drop_all
        database_names.each { |name| drop_database name }
      end

      private

        def mongo_config

          @@mongo_config ||= begin

            mongo_config = File.read( 'config/mongo.yml' ) { |f| f.read }
            template     = ERB.new( mongo_config ).result

            YAML.load template

          end
        end

    end
  end
end
