module WardenStrategies
  module Spec
    def env_with_params(path = "/", params = {})
      method = params.fetch(:method, "GET")
      Rack::MockRequest.env_for(path, :input => Rack::Utils.build_query(params),
                                     'HTTP_VERSION' => '1.1',
                                     'REQUEST_METHOD' => "#{method}")
    end
  end
end
