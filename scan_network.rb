#!/usr/bin/env ruby

## Return all device on all subnets in shiny format
## Only on 192.168 addresses
### Possible output to file?

module ScanTools
  def self.pkg_installed?
    return true if `dpkg -l`.each_line.select { |pkg| pkg.start_with?("ii  nbtscan") }
    puts("Please install nbtscan to use this tool!")
    puts("  sudo apt-get install nbtscan")
    false
  end

  def self.format_scan(subnet_scan_str)
    results = Array.new
    subnet_scan_str.each_line.select { |ln| ln.start_with?('192.168.') }.each do |r|
      results << r.strip.split(' ')[0..1].join(' --- ')
    end
    return results
  end

  def self.scan_subnet(netmask)
    ip_range = ['192', '168', netmask.to_s, '0/24'].join('.')
    return format_scan(`nbtscan #{ip_range}`)
  end
end

class NWScan
  def initialize(lo = 0, hi = 254)
    @lo = lo
    @hi = hi
    @scans = Hash.new
  end

  def scan
    puts("Scanning network @ #{Time.now.to_s}")
    (@lo..@hi).to_a.each do |sn|
      puts("Scanning subnet [#{sn.to_s}]")
      @scans[sn] = ScanTools.scan_subnet(sn)
      puts(@scans[sn])
      puts('----------')
    end
  end

  def search_by_host(hostname)
    return "Please run scan before searching!" if @scans == {}
    return @scans.each_value { |scan| scan.include?(hostname) }    
  end

  def search_by_subnet(subnet)
    return "Please run scan before searching!" if @scans == {}
    return @scans.each_key { |sn| sn == subnet }
  end
end

puts("## Network Scanner v1 ##")
x = nil
if ARGV.empty?
  x = NWScan.new
else
  puts "ARGS = #{ARGV.to_s}"
  lo = ARGV[0].to_i
  hi = ARGV[1].to_i
  x = NWScan.new(lo, hi)
end
x.scan

=begin
puts('Please specify the lower range value. [default=0]')
lo = gets.strip.to_i
puts('Please specify the upper range value. [default=254]')
hi = gets.strip.to_i
lo = lo || 0
hi = hi || 254
  x = NWScan.new(lo, hi)
#end
x.scan
=end

