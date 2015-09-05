require 'bundler/setup'
require 'emmy'

Emmy.run_block do
  request = Emmy::Http.request(
    type: 'GET',
    url:  'http://localhost:3003',
    path: '/ping',
    timeouts: { connect: 5, inactivity: 20}
  )

  puts "#{request.type} #{request.real_url}"

  response = request.sync

  puts "RESPONSE #{response.status}"
  puts response.headers
  puts response.body
end
