require 'rack'

class Occupier::HostMiddleware
  include Occupier::Helpers::Hosts

  def initialize app
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    env['tenant'] = extract_from_host(request)
    @app.call(env)
  end

  private

    def extract_from_host(request)
      hosts.fetch(request.host)
    rescue => e
      request.host.split(".").shift
    end

end
