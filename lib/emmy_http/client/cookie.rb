module EmmyHttp
  class Client::Cookie

    attr_accessor :conductor

    def initialize
      @conductor = ::CookieJar::Jar.new
    end

    def set_cookie(uri, string)
      @conductor.set_cookie(uri, string)
    rescue nil
      # ignore invalid cookies
    end

    def get_cookies(uri)
      uri ? @jar.get_cookies(uri) : []
    end

  end
end
