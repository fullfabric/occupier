require 'rack'

class Occupier::RequestMiddleware

  def initialize app
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    env['tenant'] = extract_from_request(request)
    @app.call(env)
  end

  private

    def extract_from_request(request)
      request.get_header("FF-Tenant") ||
        request.params['tenant'] ||
        request.cookies['tenant']
    end

end
