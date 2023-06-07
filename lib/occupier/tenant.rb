module Occupier

  # @api public
  class Tenant

    attr_reader :handle

    def initialize(handle, client)
      raise ::Occupier::InvalidTenantName.new(handle) unless Tenant.is_valid?(handle)

      @handle  = handle
      @client  = client
      @environment = client.environment
    end

    def self.is_valid?(handle)
      handle =~ /^[a-z]+[0-9a-z\-]*[0-9a-z]+$/ && handle.size >= 2
    end

    # Returns the names of all existing tenants for the current client environment
    #
    # == Returns:
    # An array with all the tenants
    #
    def self.all client
      databases_to_ignore = ["default", "common"]

      client.database_names.map do |name|
        name.scan(/^FF_#{client.environment}_(?!#{databases_to_ignore.join("|")})(.*)$/ )
      end.flatten.to_set
    end

    def database
      @client.database!(database_name)
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
      @client.create database_name
      connect!
      self
    end

    # Connects to specified tenant using the short form
    #
    # == Returns:
    # Occupier::Tenant
    #
    def self.connect!(handle, environment = "development", logger = nil)
      client = Occupier::MongoMapper::Connection.new(environment, logger)
      occupier = Occupier::Tenant.new(handle, client)
      occupier.connect!
    end

    # Connects to specified tenant
    #
    # == Returns:
    # Self
    #
    def connect!
      ensure_tenant_exists!
      @client.connect database_name
      self
    end

    def reset!
      @client.drop_database database_name
      create!
    end

    def purge!
      database.collections.select{ |collection| ( collection.name =~ /^system/ ).nil? }.each { |col| col.delete_many }
      self
    end

    def exists?
      @client.database_names.include? database_name
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
