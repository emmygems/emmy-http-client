require 'zlib'

module EmmyHttp
  # rfc1951
  class Client::Decoders::Deflate
    def initialize
      @i_gz = Zlib::Inflate.new(Zlib::MAX_WBITS)
    end

    def decompress(chunk)
      @i_gz.inflate(chunk)
    rescue Zlib::Error => e
      raise EmmyHttp::DecoderError, e
    end

    def finalize
      decompress(nil)
    ensure
      @i_gz.close
    end

    #<<<
  end
end
