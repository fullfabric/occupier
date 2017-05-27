module Occupier

  # @api public
  class Tenant

    attr_reader :handle

    def initialize(handle, client)
      raise ::Occupier::InvalidTenantName.new(handle) unless handle =~ /^[a-z]+$/

      @handle        = handle
      @environment   = client.environment
      @database_name = "FF_#{@environment}_#{@handle.downcase}"

      @client = client
    end

    # Returns the handles of all existing tenants for the current environment
    #
    # == Returns:
    # An array with all the handles
    #
    def self.all(client)
      client.database_names.map { |name| name.scan( /^FF_#{client.environment}_(?!default)(.*)$/ ) }.flatten.to_set
    end

    # Connects to specified tenant
    #
    # == Returns:
    # Occupier::Tenant
    #
    def connect!
      ensure_tenant_exists!
      @client.connect!(@database_name) and self
    end

    # Connects to specified tenant using the short form
    #
    # == Returns:
    # Occupier::Tenant
    #
    def self.connect!(handle, environment = "development")
      client = Occupier::Mongo::Client.new(environment)
      Occupier::Tenant.new(handle, client).connect!
    end

    # Returns the names of all existing tenants for the current connection environment
    #
    # == Returns:
    # An array with all the tenants
    #
    # def self.all(environment = "development")
    #   client = Occupier::Mongo::Client.new(environment)
    #   client.database_names.map { |name| name.scan( /^FF_#{client.environment}_(?!default)(.*)$/ ) }.flatten.to_set
    # end

    def database
      @client.database
    end

    # Creates the specified tenant if it does not exist and connects to it
    #
    # == Returns:
    # Self
    #
    def create!
      ensure_tenant_does_not_exist!
      @client.connect!(@database_name) and self
    end

    def reset!
      @client.reset! and self
    end

    def exists?
      @client.database_exists?(@database_name)
    end

    def collection(name)
      @client.collection(name)
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
