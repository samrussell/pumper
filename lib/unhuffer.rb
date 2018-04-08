require "./lib/bitstream.rb"

class Unhuffer
  FIXED_HUFFMAN_CODES = 1
  DYNAMIC_HUFFMAN_CODES = 2

  def initialize(block_file)
    @block_file = block_file
  end

  def data
    @bitstream = Bitstream.new(@block_file)
    final_flag = @bitstream.read(1)
    encoding_type = @bitstream.bits_to_number(@bitstream.read(2))
    raise "Can only handle dynamic codes" unless encoding_type == DYNAMIC_HUFFMAN_CODES

    build_huffman_table

    symbols = []
    while true
      symbol = read_fixed_symbol
      break if symbol == 256
      symbols.push(symbol)
    end

    require "byebug"
    byebug
  end

  private

  def build_huffman_table
    require "byebug"
    byebug
  end
end