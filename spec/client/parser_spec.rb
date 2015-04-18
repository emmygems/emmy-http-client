require 'spec_helper'
using EventObject

describe EmmyHttp::Client::Parser do
  let(:probe) do lambda { |*a| } end
  let(:http_request) do
    'POST /index.html HTTP/1.1
Host: domain.com
Content-Type: application/json
Content-Length: 10

{"test":1}'
  end

  let(:http_response) do
    'HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Content-Length: 2

OK'
  end


  let(:broken_response) do
    'HTTP/1.1 200 OK
Content-Length: undefined

OK'
  end

  it "parse HTTP-request head and body" do
    body = ''
    probe = lambda { |*a| }

    subject.on :head do |headers, subject|
      expect(subject.http_version).to eq([1,1])
      expect(subject.http_method).to eq('POST') # for requests
      expect(subject.request_url).to eq('/index.html')
    end

    subject.on :body do |chunk|
      body << chunk
    end

    subject.on :head, &probe
    subject.on :body, &probe
    subject.on :completed, &probe

    expect(probe).to receive(:call).exactly(3).times

    # run parse
    subject << http_request
  end

  it "parse HTTP-response head and body" do
    body = ''
    probe = lambda { |*a| }

    subject.on :head do |headers, subject|
      expect(subject.http_version).to eq([1,1])
      expect(subject.status_code).to eq(200)
    end

    subject.on :body do |chunk|
      body << chunk
    end

    subject.on :head, &probe
    subject.on :body, &probe
    subject.on :completed, &probe

    expect(probe).to receive(:call).exactly(3).times

    # run parse
    subject << http_response
  end

  it "should parser raise error" do
    expect { subject << broken_response }.to raise_exception(EmmyHttp::ParserError)
  end
end
