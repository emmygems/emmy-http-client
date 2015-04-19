module EmmyHttp
  class Client::Client
    using EventObject

    events :change

    attr_accessor :url
    attr_accessor :request
    attr_accessor :response
    attr_accessor :state

    attr_accessor :connection
    attr_accessor :operation
    attr_accessor :adapter
    attr_accessor :parser

    attr_accessor :redirects

    def initialize(request, adapter)
      @request   = request
      @adapter   = adapter
      @operation = adapter.operation
      @redirects = 0
      #@cookie    = Cookie.new
      prepare_url
      change_state(:idle)
    end


    def initialize_connection(conn)
      @connection = conn
      @parser  = Client::Parser.new
      #@parser.header_value_type = :mixed
      client = self

      conn.pending_connect_timeout = request.timeouts.connect
      conn.comm_inactivity_timeout = request.timeouts.inactivity

      conn.on :connect do
        send_request
        change_state(:wait_response)
      end

      conn.on :data do |chunk|
        begin
          parser << chunk
        rescue EmmyHttp::ParserError => e
          conn.error!(e.message)
        end
      end

      conn.on :close do
        if state == :body && !client.response.content_length?
          client.response.finish
        end

        if client.response && client.response.redirection?
          change_state(:redirect)
          client.url = URI(client.response.location)
          client.response = nil
          parser.reset!
          operation.reconnect
        end

        if client.response && client.response.finished?
          change_state(:success)
          operation.success!(response, operation, connection)
        end
      end

      conn.on :error do |message|
        change_state(:catch_error)
      end

      conn.on :handshake do

      end

      conn.on :verify_peer do

      end

      parser.on :head do |headers|
        #parser.http_version
        change_state(:body)
        client.response = EmmyHttp::Response.new(
          status: parser.status_code, # for responses
          headers: headers,
          body: ''
        )
        operation.head!(response, operation, connection)
        #parser.reset = true if request.no_body?
      end

      parser.on :body do |chunk|
        response.data!(chunk)
      end

      parser.on :completed do
        client.response.finish
        stop
      end

      change_state(:wait_connect)
    end

    def send_request
      headers = {}
      body    = prepare_body(headers)

      prepare_headers(headers)
      send_http_request(headers, body)
    end

    def prepare_url
      @url       = request.url
      @url.path  = request.path.to_s if request.path
      @url.query = request.query.is_a?(Hash) ? Encoding.query(request.query) : request.query.to_s if request.query
    end

    def prepare_body(headers)
      body, form, json, file = request.body, request.form, request.json, request.file

      if body
        raise "body cannot be hash use form attribute instead" if body.is_a?(Hash)
        body_text = body.is_a?(Array) ? body.join : body.to_s
        headers['Content-Length'] = body_text.bytesize
        body_text

      elsif form
        form_encoded = form.is_a?(String) ? form : Encoding.www_form(form)
        body_text = Encoding.rfc3986(form_encoded)
        headers['Content-Type'] = 'application/x-www-form-urlencoded'
        headers['Content-Length'] = body_text.bytesize
        body_text

      elsif json
        json_string = json.is_a?(String) ? json : (json.respond_to?(:to_json) ? json.to_json : JSON.dump(json))
        headers['Content-Length'] = json_string.size
        headers['Content-Type']   = 'application/json'
        json_string

      elsif file
        headers['Content-Length'] = File.size(file)
        nil
      else
        headers['Content-Length'] = 0 if %w('POST PUT').include? request.type
        '' # empty body
      end
    end

    def prepare_headers(headers)
      headers.merge!(EmmyHttp::Utils.convert_headers(request.headers))

      # TODO: proxy authorization

      # TODO: cookie

      headers['Connection']    = 'close' unless request.keep_alive?
      headers['User-Agent']    =  Client::USER_AGENT unless headers.key? 'User-Agent'
      headers['Authorization'] = url.userinfo.split(/:/, 2) if url.userinfo

      unless headers.key? 'Host'
        headers['Host']  = url.host
        headers['Host'] += ":#{uri.port}" unless (url.scheme == 'http'  && url.port == 80) ||
                                                 (url.scheme == 'https' && url.port == 443)
      end
    end

    def send_http_request(headers, body)

      # Send headers

      head = "#{request.type.upcase} #{url_path} #{Client::HTTP_VERSION}\r\n"
      head = headers.inject(head) { |r, (k, v)| "#{r}#{k}:#{v}\r\n" }
      head += "\r\n"
      connection.send_data head

      # Send body

      connection.send_data body if body
      connection.send_stream_file_data request.file if request.file
    end

    def url_path
      url.query ? '/' + url.path + '?' + url.query : '/' + url.path
    end

    def stop(reason='')
      connection.close_connection if connection
    end

    def change_state(new_state)
      @state = new_state
      change!(state, self)
    end

    def to_a
      ["tcp://#{url.host}:#{url.port}", connection || EmmyMachine::Connection, method(:initialize_connection), self]
    end

    #<<<
  end
end
