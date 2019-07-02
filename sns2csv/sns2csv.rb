if ARGV.length != 2
	puts "Usage: ruby sns2csv.rb <input_file> <output_file>"
	abort
end

input_file_name = ARGV[0]
output_file_name = ARGV[1]

puts "sns2csv"
puts "Loading data from #{input_file_name}"

lines = File.read(input_file_name).split(/\n/)

class Sample
	attr_accessor :time
	attr_accessor :heading
	attr_accessor :pressure1
	attr_accessor :pressure2
	attr_accessor :pressure3
	attr_accessor :temperature1
	attr_accessor :temperature2	
	attr_accessor :acceleration_x
	attr_accessor :acceleration_y
	attr_accessor :acceleration_z
end

def to_csv_line(sample)
	line = "\"#{sample.time}\""
	line += ",#{sample.heading}"
	line += ",#{sample.pressure1},#{sample.pressure2},#{sample.pressure3}"
	line += ",#{sample.acceleration_x},#{sample.acceleration_y},#{sample.acceleration_z}"
	line += ",#{sample.temperature1},#{sample.temperature2}"
end

sample = nil

File.open(output_file_name, 'w') do |out|
	out.puts "\"Time\",\"Heading\",\"Pressure 1\",\"Pressure 2\",\"Pressure 3\",\"Acceleration x\",\"Acceleration y\",\"Acceleration z\",\"Temperature 1\",\"Temperature 2\""
	lines.each do |line|
		if line.start_with?("$OLTIM")
			if sample != nil
				out.puts to_csv_line(sample)
			end
			sample = Sample.new
			sample.time = "#{line[7..10]}-#{line[11..12]}-#{line[13..14]} #{line[16..17]}:#{line[18..19]}:#{line[20..21]}"
		end

		if line.start_with?("$OLCMP")
			sample.heading = line[7..-1]
		end

		if line.start_with?("$OLPRE")
			pressure_data = line[7..-1].split(/,/)
			sample.pressure1 = pressure_data[0]
			sample.pressure2 = pressure_data[1]
			sample.pressure3 = pressure_data[2]
		end

		if line.start_with?("$OLACC")
			acceleration_data = line[7..-1].split(/,/)
			sample.acceleration_x = acceleration_data[0]
			sample.acceleration_y = acceleration_data[1]
			sample.acceleration_z = acceleration_data[2]
		end

		if line.start_with?("$OLTMP")
			temperature_data = line[7..-1].split(/,/)
			sample.temperature1 = temperature_data[0]
			sample.temperature2 = temperature_data[1]
		end
	end

	if sample != nil
		out.puts to_csv_line(sample)
	end
end

puts "Output written to #{output_file_name}"
puts "Done"