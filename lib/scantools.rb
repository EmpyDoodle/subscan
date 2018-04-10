#!/usr/bin/env ruby

## Small library for helpful functions

module ED
  def self.pkg_installed?(pkg)
    return true if `dpkg -l`.each_line.select { |pkg| pkg.start_with?("ii  #{pkg}") }
    return false
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

end
