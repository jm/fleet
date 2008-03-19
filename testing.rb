require 'lib/fleet/router'
require 'benchmark'

r = Router.new
r.route_resources("things")
r.route_resources("thangs")
r.route_resources("videos")
r.route_resources("other_things")
r.route_resources("my_things")
r.route_resources("pandas")
r.route_resources("users")
r.route_resources("sessions")
r.route_resources("bands")
r.route_resources("places")

@routes = []

content = File.open("routes.txt").read
content.split("\n").each {|line| pieces = line.split(' '); @routes << [pieces[0].to_sym, pieces[1]]}

puts "Benchmarking #{@routes.size} route(s)..."
n = 10000
GC.start
rectime = Benchmark.realtime do
  n.times do
    @routes.each do |method, path|
      r.recognize(path, method)
    end
  end
end

puts "\n\nRecognition:"
per_url = rectime / (n * @routes.size)
puts "#{per_url * 1000} ms/url"
puts "#{1 / per_url} url/s\n\n"
