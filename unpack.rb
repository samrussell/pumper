require "./lib/uncover.rb"
require "./lib/unhuffer.rb"

input_filename, output_filename = ARGV

File.open(input_filename) do |input_file|
  uncover = Uncover.new(input_file)
  block_file = uncover.block
  unhuffer = Unhuffer.new(block_file)
  data = unhuffer.data

  puts data
end