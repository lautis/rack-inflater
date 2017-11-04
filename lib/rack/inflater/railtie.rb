module Rack
  class Inflater
    class Railtie < ::Rails::Railtie
      initializer "rack-inflater.railtie" do |app|
        app.middleware.use ::Rack::Inflater
      end
    end
  end
end
