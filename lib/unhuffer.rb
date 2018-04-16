require "./lib/bitstream.rb"
require "./lib/length_decoder.rb"
require "./lib/distance_decoder.rb"
require "./lib/lz77_decoder.rb"
require "./lib/build_huffman_tables.rb"

class Unhuffer
  FIXED_HUFFMAN_CODES = 1
  DYNAMIC_HUFFMAN_CODES = 2

  def initialize(block_file)
    @block_file = block_file
  end

  def data
    @bitstream = Bitstream.new(@block_file)

    read_header

    huffman_table_builder = BuildHuffmanTables.new(@bitstream)

    @literal_length_table = huffman_table_builder.literal_length_table
    @distance_table = huffman_table_builder.distance_table

    lz77_encoded_data = decode_huffman

    symbols = Lz77Decoder.new(lz77_encoded_data).decode.to_a

    symbols.map(&:chr).join
  end

  private

  def decode_huffman_symbols
    return enum_for(:decode_huffman_symbols) unless block_given?

    while true
      symbol = @literal_length_table.decode(@bitstream)

      break if symbol == 256

      if symbol < 256
        yield symbol.chr
      else
        length = @length_decoder.decode(symbol)
        distance_prefix = @distance_table.decode(@bitstream)
        distance = @distance_decoder.decode(distance_prefix)

        yield [distance, length]
      end
    end
  end

  def decode_huffman
    @length_decoder = LengthDecoder.new(@bitstream)
    @distance_decoder = DistanceDecoder.new(@bitstream)

    decode_huffman_symbols.to_a
  end

  def read_header
    final_flag = @bitstream.read(1)
    encoding_type = @bitstream.read_number(2)
    raise "Can only handle dynamic codes" unless encoding_type == DYNAMIC_HUFFMAN_CODES
  end
end