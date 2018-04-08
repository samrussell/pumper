require "./lib/bitstream.rb"

class Unhuffer
  FIXED_HUFFMAN_CODES = [0, 1]

  def initialize(block_file)
    @block_file = block_file
  end

  def data
    @bitstream = Bitstream.new(@block_file)
    header = @bitstream.read(3)
    final_flag = header[0]
    encoding_type = header[1..2]
    raise "Can only handle fixed codes" unless encoding_type == FIXED_HUFFMAN_CODES

    symbols = []
    while true
      symbol = read_symbol
      break if symbol == 256
      symbols.push(symbol)
    end

    require "byebug"
    byebug
  end

  private

  def read_symbol
    initial_bits = @bitstream.read(4)
    # TODO this should be read_as_byte on bitstream
    initial_value = @bitstream.bits_to_number(initial_bits)
    # 00000000 - 00101111
    if initial_value <= "0010".to_i(2)
      coded_symbol = @bitstream.bits_to_number(initial_bits + @bitstream.read(3))
      coded_symbol + 256
    # 00110000 - 10111111
    elsif initial_value <= "1011".to_i(2)
      coded_symbol = @bitstream.bits_to_number(initial_bits + @bitstream.read(4))
      coded_symbol - "00110000".to_i(2)
    else
      initial_bits += @bitstream.read(1)
      initial_value = @bitstream.bits_to_number(initial_bits)
      # 11000000 - 11000111
      if initial_value == "11000".to_i(2)
        coded_symbol = @bitstream.bits_to_number(initial_bits + @bitstream.read(3))
        coded_symbol - "11000000".to_i(2) + 280
      # 110010000 - 111111111
      else
        coded_symbol = @bitstream.bits_to_number(initial_bits + @bitstream.read(4))
        coded_symbol - "110010000".to_i(2) + 144
      end
    end
  end
end