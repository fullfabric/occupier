module Occupier

  # @api public
  class Tenant

    include Contracts::Core
    include Contracts::Builtin

    attr_reader :handle

    Contract String, Occupier::Mongo::Connection, Occupier::Pg::Connection => Occupier::Tenant
    def initialize(handle, conn_mongo, conn_pg = nil)

      raise ::Occupier::InvalidTenantName.new(handle) unless handle =~ /^[a-z]+$/

      @handle     = handle
      @conn_mongo = conn_mongo
      @conn_pg    = conn_pg

      @environment = @conn_mongo.environment

      self

    end

    # Returns the names of all existing tenants for the current connection environment
    #
    # == Returns:
    # An array with all the tenants
    #
    def self.all connection
      connection.database_names.map { |name| name.scan( /^FF_#{connection.environment}_(?!default)(.*)$/ ) }.flatten.to_set
    end

    def database
      @conn_mongo.database database_name
    end

    def database_name
      @database_name ||= "FF_#{@environment}_#{@handle.downcase}"
    end

    # Creates the specified tenant if it does not exist and connects to it
    #
    # == Returns:
    # Self
    #
    def create!
      ensure_tenant_does_not_exist!
      @conn_mongo.create(database_name)
      (@conn_pg.create(database_name) if @conn_pg) rescue nil
      connect!
      self
    end

    # Connects to specified tenant using the short form
    #
    # == Returns:
    # Occupier::Tenant
    #
    def self.connect! handle, environment = "development"
      conn_mongo = Occupier::MongoMapper::Connection.new(environment)
      conn_pg = Occupier::Pg::Connection.new(environment)

      Occupier::Tenant.new(handle, conn_mongo, conn_pg).connect!
    end

    # Connects to specified tenant
    #
    # == Returns:
    # Self
    #
    def connect!
      ensure_tenant_exists!
      @conn_mongo.connect(database_name)
      (@conn_pg.connect(database_name) if @conn_pg) rescue nil
      self
    end

    def close
      @conn_mongo.close
      (@conn_pg.close if @conn_pg) rescue nil
    end

    def reset!
      @conn_mongo.drop_database database_name
      create!
    end

    def purge!
      database.collections.select{ |collection| ( collection.name =~ /^system/ ).nil? }.each( &:remove )
      self
    end

    def exists?
      @conn_mongo.database_names.include? database_name
    end

    private

      def ensure_tenant_exists!
        raise ::Occupier::NotFound.new("tenant #{@handle} not found in environment #{@environment}") unless exists?
      end

      def ensure_tenant_does_not_exist!
        raise ::Occupier::AlreadyExists.new("tenant #{@handle} already exists in environment #{@environment}") if exists?
      end

  end
end
