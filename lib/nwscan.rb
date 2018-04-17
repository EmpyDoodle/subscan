#!/usr/bin/env ruby

## Return all device on all subnets in shiny format
## Only on 192.168 addresses
### Possible output to file?

require_relative 'scantools.rb'

class NWScan
  def initialize(lo = 0, hi = 254)
    @lo = lo
    @hi = hi
    @time = Time.now
    @scans = Hash.new
    @id = @time.strftime("%d%m%Y-%H%M")
  end

  def scan
    puts("Scanning network @ #{@time.to_s}")
    (@lo..@hi).to_a.each do |sn|
      puts("Scanning subnet [192.168.#{sn.to_s}.x]")
      @scans[sn] = ScanTools.scan_subnet(sn)
      puts(@scans[sn])
      puts('----------')
    end
    return "Error: No devices are in scan list. Please run scan again" if @scans == {}
  end

  def scan_slow()  ## Fallback option
    puts("Scanning network @ #{@time.to_s}")
    (@lo..@hi).to_a.each do |sn|
      puts("Scanning subnet [192.168.#{sn.to_s}.x]")
      @scans[sn] = ScanTools.scan_subnet(sn)
      puts(@scans[sn])
      puts('----------')
    end
    return "Error: No devices are in scan list. Please run scan again" if @scans == {}
  end

  def search_by_host(hostname)
    return "Please run scan before searching!" if @scans == {}
    search_matches = Array.new
    @scans.each_value do |scan| 
      search_matches << scan.select { |dvc| dvc.include?(hostname) }
    end
    return search_matches.flatten
  end

  def search_by_subnet(subnet)
    return "Please run scan before searching!" if @scans == {}
    return @scans[subnet]
  end

  def write_to_file(file_path = File.join('/', 'tmp', "subscan_#{@id}.txt"))
    puts("Writing scan results to #{file_path}")
    File.open(file_path, 'w+') do |f|
      f.puts('### Subscan v1 ###')
      f.puts("Scan ID: #{@id}")
      f.puts("Network scanned @ #{@time.to_s}")
      f.puts('')
      @scans.each do |sn, sc|
        mask = ['192', '168', sn.to_s, 'x'].join('.')
        f.puts("Devices on #{mask}:")
        sc.each { |dvc| f.puts("+ #{dvc}") }
        f.puts('')
      end
      f.puts('## Finished scan ##')
    end
  end
end
