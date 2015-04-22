// Test server for emmy-http-client tests
var http = require("http");

http.createServer(function(request, response) {
  console.log(request.method + ' ' + request.url);
  if (request.url == '/') {
    response.writeHead(200, {"Content-Type": "text/plain"});
    response.write("OK");
  }

  response.end();
}).listen(10240);
