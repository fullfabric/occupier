module Occupier

  module MongoMapper

    # @api public
    class Connection < ::Occupier::Mongo::Client
      # Note: we're keeping the "Connection" designation to match MongoMapper's
      # terminology, but this is in fact a Client.

      def initialize environment = "development", logger = nil
        super
        ::MongoMapper.connection = client
      end

      def connect database_name
        ::MongoMapper.database = database_name
        true
      end

      def current_database
        ::MongoMapper.database.name
      end

    end

  end
end