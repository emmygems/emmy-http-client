require 'spec_helper'
require 'logger'
require 'open-uri'

begin
  open('http://localhost:10240')
rescue
  puts 'Local server does not run'
  exit
end

describe EmmyHttp::Client do
  around do |example|
    EmmyMachine.run_block &example
  end

  it 'has a version number' do
    expect(EmmyHttp::Client::VERSION).not_to be nil
  end

  it 'do get request to local server' do
    request   = EmmyHttp::Request.new(url: 'http://localhost:10240')
    operation = EmmyHttp::Operation.new(request, EmmyHttp::Client::Adapter.new)
    response  = operation.sync

    expect(response.status).to be(200)
    expect(response.body).to_not be_empty
    expect(response.content_type).to eq("text/plain")
  end

end
