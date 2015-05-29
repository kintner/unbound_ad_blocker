#!/bin/ruby

require 'open-uri'
require 'hosts'
require 'byebug'

urls = %w(
  https://adaway.org/hosts.txt
  http://winhelp2002.mvps.org/hosts.txt
  http://hosts-file.net/ad_servers.asp
  http://someonewhocares.org/hosts/zero/hosts
  )

domains = []

urls.each do |url|
  hosts = Hosts::File.parse(open(url).read)
  domains += hosts.elements.select { |h| h.is_a?(Aef::Hosts::Entry) }.map(&:name)
end

domains = domains.map(&:strip).map(&:strip).sort.uniq

domains - ["localhost"]

File.open("local-blocking-data.conf", "w") do |fh|
  domains.each do |d|
    fh << %{local-data: "#{d} A 0.0.0.0"\n}
    fh << %{local-data: "#{d} AAAA ::1"\n}
  end
end

File.open("hosts", "w") do |fh|
  domains.each do |d|
    fh << %{0.0.0.0 #{d}\n}
  end
end
