require 'spec_helper'

describe EmmyHttp::Client do
  around do |example|
    EmmyMachine.run_block &example
  end

  it 'has a version number' do
    expect(EmmyHttp::Client::VERSION).not_to be nil
  end

  it 'do GET request' do
    request   = EmmyHttp::Request.new(url: 'http://httpbin.org/get')
    operation = EmmyHttp::Operation.new(request, EmmyHttp::Client::Adapter.new)
    response  = operation.sync

    expect(response.status).to be(200)
    expect(response.body).to_not be_empty
    expect(response.content_type).to eq("text/html")
  end

  it 'do POST form' do
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

  it 'do POST json' do
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

end
