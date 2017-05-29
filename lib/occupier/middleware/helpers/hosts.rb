module Occupier
  module Helpers
    module Hosts

      def hosts
        config = YAML.load_file("#{Rails.root}/config/hosts.yml")
        config.fetch(Rails.env, {})
      rescue
        {}
      end

      def tenants
        @tenants ||= hosts.invert
      end

      def has_custom_host?(env)
        tenants.has_key?(env['tenant'])
      end

      def is_custom_host?(env)
        hosts.has_key?(env['host'])
      end

      def canonical_host(env)
        "#{env['tenant']}.fullfabric.com"
      end

      def custom_host(env)
        tenants[env['tenant']]
      end

    end
  end
end
