if ARGV.length != 2
	puts "Usage: ruby nmea2gpx.rb <nmea_input_file> <gpx_output_name>"
	abort
end

input_file_name = ARGV[0]
output_file_name = ARGV[1]
track_template_file_name = "gpx_template.gpx"
track_points_placeholder = "${points}"

puts "Processing file #{input_file_name}"
input = File.read(input_file_name).split(/\n/)

class TrackPoint
	attr_accessor :date_time_UTC
	attr_accessor :latitude
	attr_accessor :longitude
	attr_accessor :elevation
end

track_points = []

current_track_point = nil
input.select{|x| x.start_with?("$GP")}.each do |line|

	if line.start_with?("$GPGGA")
		current_track_point = TrackPoint.new

		tokens = line.split(/,/)
		elevation_token = tokens[9]
		current_track_point.elevation = elevation_token.to_f
	end

	if line.start_with?("$GPRMC")
		tokens = line.split(/,/)
		time_token = tokens[1]
		date_token = tokens[9]
		latitude_token = tokens[3]
		longitude_token = tokens[5]

		time = "#{time_token[0..1]}:#{time_token[2..3]}:#{time_token[4..5]}"
		date = "20#{date_token[4..5]}-#{date_token[2..3]}-#{date_token[0..1]}"
		current_track_point.date_time_UTC = "#{date}T#{time}Z"

		current_track_point.latitude = latitude_token[0..1].to_i + latitude_token[2..-1].to_f / 60
		current_track_point.longitude = longitude_token[0..2].to_i + longitude_token[3..-1].to_f / 60

		track_points << current_track_point
	end

end
#
#$GPGGA,055024.000,5420.9864,N,01831.9751,E,1,6,,138.0,M,,M,,*57
puts "Loaded #{track_points.length} track points"

puts "Loading track template from #{track_template_file_name}"
track = File.read(track_template_file_name)

track_points_xml = track_points.map { |p| "<trkpt lat=\"#{'%.6f' % p.latitude}\" lon=\"#{'%.6f' % p.longitude}\"><time>#{p.date_time_UTC}</time><ele>#{'%.1f' % p.elevation}</ele></trkpt>" }.join("\n")
track = track.gsub(track_points_placeholder, track_points_xml)

File.open(output_file_name, 'w') { |f| f.write(track)}
puts "Output written to #{output_file_name}"
puts "Done"