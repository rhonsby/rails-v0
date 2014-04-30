require 'webrick'

server = WEBrick::HTTPServer.new :Port => 3000

server.mount_proc('/') do |req, res|
  res.body = req.path
  res['Content-Type'] = 'text/text'
end

trap('INT') { server.shutdown }
server.start
