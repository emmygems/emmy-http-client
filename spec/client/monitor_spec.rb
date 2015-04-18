require 'spec_helper'
require 'logger'
using EventObject

describe EmmyHttp::Client::Monitor do
  around do |example|
    EmmyMachine.run_block &example
  end

  it "display http logs", current: true do
    request   = EmmyHttp::Request.new(url: 'http://google.com')
    operation = EmmyHttp::Operation.new(request, EmmyHttp::Client::Adapter.new)

    monitor = EmmyHttp::Client::Monitor.new
    monitor.logger = Logger.new(STDOUT)
    monitor.bind(operation)

    response = operation.sync
  end
end
