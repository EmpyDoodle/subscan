#!/usr/bin/env ruby

## Small library for helpful functions

module ED
  def self.pkg_installed?(pkg)
    return true if `dpkg -l`.each_line.select { |pkg| pkg.start_with?("ii  #{pkg}") }
    return false
  end

  def self.do_in_child()
    read, write = IO.pipe
    pid = fork do
      read.close
      result = yield
      Marshal.dump(result, write)
      exit!(0) # skips exit handlers.
    end
    write.close
    result = read.read
    Process.wait(pid)
    raise "child failed" if result.empty?
    Marshal.load(result)
  end
end

module ScanTools
  def self.pkg_check
    return true if ED.pkg_installed?('nbtscan')
    abort('Please install nbtscan to use this tool!')
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

  def self.scan(subnet)
    puts("Scanning subnet [192.168.#{subnet.to_s}.x]")
    read, write = IO.pipe
    result = nil
    pid = fork do
      read.close
      result = ScanTools.scan_subnet(subnet)
#      Marshal.dump(result, write)
      exit!(0)
    end
    write.close
#    result = read.read
#    Process.wait(pid)
#    return Marshal.load(result).first
    Marshal.dump(result, write)
  end

end
