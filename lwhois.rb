require 'yaml'
require 'ipaddr'

class Lwhois
  def initialize(db_filename)
    @entries = YAML.load_file(db_filename)
  end

  def query_subdomain(ipaddress)
    @entries.each {|entry|
      return entry[:domain] if IPAddr.new(entry[:network]).include?(ipaddress)
    }
    printf("%s: no match!\n", ipaddress)
    exit(1)
  end
end
