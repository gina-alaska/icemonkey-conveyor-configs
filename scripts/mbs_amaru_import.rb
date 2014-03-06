#!/usr/bin/env ruby
# Process the Mass Balance Site CSV file and import into Amaru via the REST interface.

require 'net/http'
require 'uri'

# Handle the command line and get the parameters
if ARGV.length <= 1 or ARGV.length > 4
  puts "Usage:\nmbs_amaru_import.rb {import file} {host name} {platform slug} {access token}\n\n"
  exit -1
end

filename = ARGV.shift
hostname = ARGV.shift
platform = ARGV.shift
token = ARGV.shift

# Open data file
if File.exists?(filename)
  fhandle = File.open(filename, "r")
else
  puts "I can't open the import file \"#{filename}\"!"
  exit -1
end

# Check the file handle and make sure that it's good
if !fhandle
  puts "There was a problem reading in the data file \"#{filename}\"!"
  exit -1
end

# Process data so it can be imported into Amaru
fhandle.gets            # Skip the first line
header = fhandle.gets   # Get the header line
header = header.gsub("TIMESTAMP", "date") # convert TIMESTAMP to date

# Read through the file and pull the last three entries off the end (45 min. of data)
buff1, buff2, buff3 = ""
while line = fhandle.gets
  buff1 = buff2
  buff2 = buff3
  buff3 = line
end

# Send the data to Amaru via the Rest import
uri = URI.parse("#{hostname}/csv/#{platform}/#{token}")
puts uri
begin
  Net::HTTP.post_form(uri, {"data" => (header + buff1 + buff2 + buff3).chomp.chomp})
rescue => e
  puts e.inspect
  puts e.backtrace
end
