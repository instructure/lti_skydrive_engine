require 'raven'

module Skydrive
  class RavenLogger
    ENV_KEY = "RAVEN_SKYDRIVE_DSN"

    def self.capture_exception(error)
      return if Rails.env.test?
      if (ENV[ENV_KEY])
        config = Raven.configuration
        config.dsn = ENV.fetch(ENV_KEY)
      end
      Raven.capture_exception(error, {configuration: config})
    end
  end
end
