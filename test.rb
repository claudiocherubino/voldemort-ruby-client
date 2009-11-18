require 'store_client'

s = StoreClient.new("test", [["localhost", "6666"]])
version = s.put("hello", "1")
raise "Invalid result" unless s.get("hello")[0][0] == "1"
s.put("hello", "2", version)
raise "Invalid result" unless s.get("hello")[0][0] == "2"
s.put("hello", "3")
raise "Invalid result" unless s.get("hello")[0][0] == "3"
s.delete("hello")
raise "Invalid result" unless s.get("hello").size == 0

## test get_all
pairs = [["a1", "1"], ["a2", "2"], ["a3", "3"], ["a4", "4"]]
pairs.each { |k,v| s.put(k,v) }
    
vals = s.get_all(pairs.map { |k,v| k }  )
pairs.each { |k,v|
  raise "Invalid result" unless vals[k][0][0] == v
}

requests = 10000

## Time get requests
s.put("hello", "world")
start = Time.new
[1..requests].each { s.get('hello') }
puts "#{requests/(Time.new - start)} get requests per second"

## Time put requests
version = s.put('abc', 'def')
start = Time.new
[1..requests].each { version = s.put('abc', 'def', version) }
puts "#{requests/(Time.new - start)} put requests per second"

## Time get_all requests
keys = pairs.map { |k,v| k }
start = Time.new
[1..requests].each { vals = s.get_all(keys) }
puts "#{requests/(Time.new - start)} get_all requests per second"

## Time delete requests
version = nil
[1..requests].each { |i| version = s.put(i.to_s, i.to_s) }
start = Time.new
[1..requests].each { |i| vals = s.delete(i.to_s, version) }
puts "#{requests/(Time.new - start)} delete requests per second"
