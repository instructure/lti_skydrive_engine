require "skydrive/engine"

module Skydrive


  class OAuthStateException < RuntimeError
  end

  class APIErrorException < RuntimeError
  end

  class APIResponseErrorException < RuntimeError
    attr_reader :response, :code, :description
    def initialize(response)
      @response = response
      @code = response['error']
      @description = response['error_description']
      super("#{@code}: #{@description}\n#{response}")
    end
  end

  class << self
    attr_accessor :logger
  end
end
