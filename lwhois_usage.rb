#!~/.rbenv/shims/ruby

require 'optparse'
require 'pp'
require './lwhois.rb'

opt = OptionParser.new
OPTS = Hash.new
opt.on('-f VAL', '--db-filename VAL') {|v| OPTS[:db_filename] = v}
opt.parse!(ARGV)

if ! OPTS[:db_filename]
  print "--db-filename [local-whois DB YAML filename] is required.\n"
  exit(1)
end

network = Lwhois.new(OPTS[:db_filename])

queries = Array.new
queries << ARGV[0] if ARGV[0] 
if File.pipe?(STDIN) || File.select([STDIN], [], [], 0) != nil
  STDIN.each_line {|line|
    queries << line.chop
  }
end

if queries.empty?
  print "At least one IP address is required.\n"
  exit(1)
end

result_hash = Hash.new

queries.each {|ipaddr|
  subdomain_name = network.query_subdomain(ipaddr)
  result_hash[subdomain_name] = Array.new if ! result_hash.key?(subdomain_name)
  result_hash[subdomain_name] << ipaddr
}

date = Date.today.strftime('%Y%m%d')

result_hash.each{|subdomain_name,ip_addresses|
  prefix = date + "_" + subdomain_name
  unique_prefix = prefix
  n = 2
  while Dir.exist?(unique_prefix) do
    unique_prefix = unique_prefix + n.to_s
    n = n + 1
  end
  Dir.mkdir(unique_prefix)
  filename = unique_prefix + '/' + unique_prefix + '.dat'
  File.open(filename, 'w') {|file|
    ip_addresses.each{|ip_address|
      file.puts(ip_address)
    }
  }
}
