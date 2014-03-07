module Occupier

  # @api public
  class Tenant

    attr_reader :handle

    def initialize handle, connection

      raise ::Occupier::InvalidTenantName.new(handle) unless handle =~ /^[a-z]+$/

      @handle = handle
      @connection = connection
      @environment = connection.environment

    end

    # Returns the names of all existing tenants for the current connection environment
    #
    # == Returns:
    # An array with all the tenants
    #
    def self.all connection
      connection.database_names.map { |name| name.scan /^FF_#{connection.environment}_(?!default)(.*)$/ }.flatten.to_set
    end

    def database
      @connection.database database_name
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
      @connection.create database_name
      connect!
      self
    end

    # Connects to specified tenant using the short form
    #
    # == Returns:
    # Occupier::Tenant
    #
    def self.connect! handle, environment = "development"
      connection = Occupier::MongoMapper::Connection.new environment
      Occupier::Tenant.new(handle, connection).connect!
    end

    # Connects to specified tenant
    #
    # == Returns:
    # Self
    #
    def connect!
      ensure_tenant_exists!
      @connection.connect database_name
      self
    end

    def reset!
      @connection.drop_database database_name
      create!
    end

    def purge!
      database.collections.select{ |collection| ( collection.name =~ /^system/ ).nil? }.each( &:remove )
      self
    end

    def exists?
      @connection.database_names.include? database_name
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