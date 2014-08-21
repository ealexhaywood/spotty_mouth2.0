class Rack::Www
  def initialize(app)
    @app = app
  end
  def call(env)
    if env['SERVER_NAME'] =~ /^www\./
      @app.call(env)
    else
      [ 307, { 'Location' => 'http://www.spottymouth.com/' }, '' ]
    end
  end
end