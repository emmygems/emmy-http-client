require 'spec_helper'

describe EmmyHttp::Client do
  around do |example|
    EmmyMachine.run_block &example
  end

  it 'has a version number' do
    expect(EmmyHttp::Client::VERSION).not_to be nil
  end

  it 'do GET request' do
    request   = EmmyHttp::Request.new(url: 'http://google.com')#'http://httpbin.org')
    operation = EmmyHttp::Operation.new(request, EmmyHttp::Client::Adapter.new)
    response  = operation.sync

    expect(response.status).to be(200)
    expect(response.body).to_not be_empty
    expect(response.content_type).to eq("text/html")
  end
end
