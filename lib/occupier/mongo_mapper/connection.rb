module Occupier

  module MongoMapper

    # @api public
    class Connection < ::Occupier::Mongo::Connection

      def initialize environment = "development", logger = nil
        super
        ::MongoMapper.connection = connection
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