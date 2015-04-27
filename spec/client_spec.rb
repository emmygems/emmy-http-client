require 'spec_helper'
require 'logger'

describe EmmyHttp::Client do
  around do |example|
    EmmyMachine.run_block &example
  end

  it 'does GET request' do
    request   = EmmyHttp::Request.new(url: 'http://httpbin.org/get')
    operation = EmmyHttp::Operation.new(request, EmmyHttp::Client::Adapter.new)
    response  = operation.sync

    expect(response.status).to be(200)
    expect(response.body).to_not be_empty
    expect(response.content_type).to eq("application/json")
  end

  it "does GET with url template" do
    request   = EmmyHttp::Request.new(
      url: 'http://httpbin.org/bytes{/bytes}',
      params: {
        bytes: 1024
      }
    )
    operation = EmmyHttp::Operation.new(request, EmmyHttp::Client::Adapter.new)
    response  = operation.sync

    expect(response.status).to be(200)
    expect(response.body.size).to be(1024)
  end

  it "does GET with path template" do
    request   = EmmyHttp::Request.new(
      url: 'http://httpbin.org',
      path: '/bytes{/bytes}',
      params: {
        bytes: 1024
      }
    )
    operation = EmmyHttp::Operation.new(request, EmmyHttp::Client::Adapter.new)
    response  = operation.sync

    expect(response.status).to be(200)
    expect(response.body.size).to be(1024)
  end

  it 'does POST form' do
    request   = EmmyHttp::Request.new(
      type: 'POST',
      url: 'http://httpbin.org/post',
      form: {'first_name' => 'John', 'last_name' => 'Due'}
    )
    operation = EmmyHttp::Operation.new(request, EmmyHttp::Client::Adapter.new)
    response  = operation.sync

    expect(response.status).to be(200)
    expect(response.content_type).to eq("application/json")
    expect(response.content["form"]).to include("first_name"=>"John", "last_name"=>"Due")
  end

  it 'does POST json' do
    request   = EmmyHttp::Request.new(
      type: 'POST',
      url: 'http://httpbin.org/post',
      json: {points: [{x:5, y:6}, {x:3, y:2}]}
    )
    operation = EmmyHttp::Operation.new(request, EmmyHttp::Client::Adapter.new)
    response  = operation.sync

    expect(response.status).to be(200)
    expect(response.content_type).to eq("application/json")
    expect(response.content["json"]).to include('points' => [{'x' => 5, 'y' => 6}, {'x' => 3, 'y' => 2}])
  end

  it 'does HTTPS request' do
    request   = EmmyHttp::Request.new(url: 'https://httpbin.org/get')
    operation = EmmyHttp::Operation.new(request, EmmyHttp::Client::Adapter.new)
    response  = operation.sync

    expect(response.status).to be(200)
    expect(response.content_type).to eq("application/json")
    expect(response.content).to_not be_empty
  end

  it 'should HTTP connection keep alive' do
    request1   = EmmyHttp::Request.new(url: 'http://httpbin.org', keep_alive: true)
    operation1 = EmmyHttp::Operation.new(request1, EmmyHttp::Client::Adapter.new)

    # send first request
    response1  = operation1.sync

    request2   = EmmyHttp::Request.new(url: 'http://httpbin.org')
    operation2 = EmmyHttp::Operation.new(request2, EmmyHttp::Client::Adapter.new, operation1.connection)

    # try send again
    response2  = operation2.sync

    expect(response1.status).to be(200)
    expect(response2.status).to be(200)
  end

  it 'has gzipped request body', skip: true do
    request   = EmmyHttp::Request.new(
      type: 'POST',
      url: 'http://httpbin.org/post',
      headers: { 'Content-Encoding' => 'gzip' },
      form: { p1: 1, p2: 2 }
    )
    operation = EmmyHttp::Operation.new(request, EmmyHttp::Client::Adapter.new)
    response  = operation.sync

    expect(response.status).to be(200)
    expect(response.content['headers']['Content-Encoding']).to eq('gzip')
  end

  it 'has deflated response' do
    request   = EmmyHttp::Request.new(url: 'http://httpbin.org/deflate')
    operation = EmmyHttp::Operation.new(request, EmmyHttp::Client::Adapter.new)
    response  = operation.sync

    expect(response.status).to be(200)
    expect(response.content["deflated"]).to be true
  end

  it 'has gzipped response', skip: true do
    request   = EmmyHttp::Request.new(url: 'http://httpbin.org/gzip')
    operation = EmmyHttp::Operation.new(request, EmmyHttp::Client::Adapter.new)
    response  = operation.sync

    expect(response.status).to be(200)
    expect(response.content["gzipped"]).to be true
  end

  it 'raises connection refused' do
    expect {
      request   = EmmyHttp::Request.new(url: 'http://localhost:10450')
      operation = EmmyHttp::Operation.new(request, EmmyHttp::Client::Adapter.new)

      response  = operation.sync
    }.to raise_error 'Connection refused'
  end

  it 'has 302 Absolute redirects' do
    request   = EmmyHttp::Request.new(url: 'http://httpbin.org/absolute-redirect/2')
    operation = EmmyHttp::Operation.new(request, EmmyHttp::Client::Adapter.new)
    response  = operation.sync

    expect(response.status).to be(200)
    expect(response.body).to_not be_empty
    expect(response.content_type).to eq("application/json")
  end

  it 'has 302 Relative redirects' do
    request   = EmmyHttp::Request.new(url: 'http://httpbin.org/relative-redirect/2')
    operation = EmmyHttp::Operation.new(request, EmmyHttp::Client::Adapter.new)
    response  = operation.sync

    expect(response.status).to be(200)
    expect(response.body).to_not be_empty
    expect(response.content_type).to eq("application/json")
  end

  it 'has timeout request' do
    request   = EmmyHttp::Request.new(
      url: 'http://httpbin.org/delay/2',
      timeouts: { connect: 10, inactivity: 1 }
    )
    operation = EmmyHttp::Operation.new(request, EmmyHttp::Client::Adapter.new)
    expect { operation.sync }.to raise_error EmmyHttp::ConnectionError
  end

  it "send request with authorization" do
    request   = EmmyHttp::Request.new(url: 'http://test:123@httpbin.org/basic-auth/test/123')
    operation = EmmyHttp::Operation.new(request, EmmyHttp::Client::Adapter.new)
    response  = operation.sync

    expect(response.status).to be(200)
    expect(response.content_type).to eq("application/json")
    expect(response.content["authenticated"]).to be true
  end
end
