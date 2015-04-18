require 'event_object'
require 'emmy_http'
require 'fibre'
require 'emmy_machine'

require "emmy_http/client/version"
require "emmy_http/client/cookie"
require "emmy_http/client/parser"
require "emmy_http/client/adapter"
require "emmy_http/client/client"
require "emmy_http/client/encoding"

module EmmyHttp
  class ParserError < StandardError; end

  module Client
    USER_AGENT   = 'emmy-http'.freeze
    HTTP_VERSION = 'HTTP/1.1'.freeze

    autoload :Monitor, "emmy_http/client/monitor"
  end
end
