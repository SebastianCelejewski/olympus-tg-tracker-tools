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

track_points = []
input.select{|x| x.start_with?("$GPRMC")}.each do |line|
	tokens = line.split(/,/)
	time_token = tokens[1]
	date_token = tokens[9]
	latitude_token = tokens[3]
	longitude_token = tokens[5]

	time = "#{time_token[0..1]}:#{time_token[2..3]}:#{time_token[4..5]}"
	date = "20#{date_token[4..5]}-#{date_token[2..3]}-#{date_token[0..1]}"
	date_time = "#{date}T#{time}Z"

	latitude = latitude_token[0..1].to_i + latitude_token[2..-1].to_f / 60
	longitude = longitude_token[0..2].to_i + longitude_token[3..-1].to_f / 60
	track_points << "<trkpt lat=\"#{latitude}\" lon=\"#{longitude}\"><time>#{date_time}</time></trkpt>"
end

puts "Loaded #{track_points.length} track points"

puts "Loading track template from #{track_template_file_name}"
track = File.read(track_template_file_name)
track = track.gsub(track_points_placeholder, track_points.join("\n"))

File.open(output_file_name, 'w') { |f| f.write(track)}
puts "Output written to #{output_file_name}"
puts "Done"