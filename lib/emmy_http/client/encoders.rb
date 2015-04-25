module EmmyHttp
  module Encoders
    extend self

    def escape(str)
      str.gsub(/([^a-zA-Z0-9_.-]+)/) { '%'+$1.unpack('H2'*$1.bytesize).join('%').upcase }
    end

    def rfc3986(str)
      str.gsub(/([!'()*]+)/m) { '%'+$1.unpack('H2'*$1.bytesize).join('%').upcase }
    end

    def www_form(enum)
      URI.encode_www_form(enum)
    end

    def query(query)
      query.map { |k, v| param(k, v) }.join('&')
    end

    def param(k, v)
      if v.is_a?(Array)
        v.map { |e| escape(k) + "[]=" + escape(e) }.join("&")
      else
        escape(k) + "=" + escape(v)
      end
    end

    def encode_auth(userinfo)
      "Basic #{Base64.strict_encode64(userinfo)}"
    end

    def encode_body(encoding, body)
      require 'zlib'
      require 'stringio'

      case encoding
      when "gzip"
        wio = StringIO.new("w")
        begin
          w_gz = Zlib::GzipWriter.new(wio)
          w_gz.write(body)
        rescue
          raise EmmyHttp::EncoderError
        ensure
          w_gz.close
        end
        wio.string
      else
        body
      end
    end

    #<<<
  end
end
