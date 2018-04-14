require "./lib/bitstream.rb"
require "./lib/huffman_table.rb"
require "./lib/length_decoder.rb"
require "./lib/distance_decoder.rb"
require "./lib/code_length_decoder.rb"
require "./lib/lz77_decoder.rb"

class Unhuffer
  FIXED_HUFFMAN_CODES = 1
  DYNAMIC_HUFFMAN_CODES = 2
  CODE_LENGTHS_ARRAY = [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15]
  MINIMUM_LITERAL_LENGTH_CODES = 257
  MINIMUM_DISTANCE_CODES = 1
  MINIMUM_CODE_LENGTH_CODES = 4

  def initialize(block_file)
    @block_file = block_file
  end

  def data
    @bitstream = Bitstream.new(@block_file)

    read_header

    build_huffman_tables

    lz77_encoded_data = decode_huffman

    symbols = Lz77Decoder.new.decode(lz77_encoded_data)

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

  def build_huffman_tables
    num_literal_length_codes = MINIMUM_LITERAL_LENGTH_CODES + @bitstream.read_number(5)
    num_distance_codes = MINIMUM_DISTANCE_CODES + @bitstream.read_number(5)
    num_code_length_codes = MINIMUM_CODE_LENGTH_CODES + @bitstream.read_number(4)
    unsorted_code_length_codes = num_code_length_codes.times.map { @bitstream.read_number(3) }
    code_lengths_dictionary = CODE_LENGTHS_ARRAY.zip(unsorted_code_length_codes).each.with_object({}) do |(code, length), hash|
      if length && length > 0
        hash[code] = length
      else
        hash[code] = nil
      end
    end
    code_lengths = code_lengths_dictionary.sort.map {|x| x[1]}

    code_length_table = HuffmanTable.new(code_lengths)

    literal_length_codes = CodeLengthDecoder.new(@bitstream, code_length_table).decode(num_literal_length_codes)
    @literal_length_table = HuffmanTable.new(literal_length_codes)

    distance_codes = CodeLengthDecoder.new(@bitstream, code_length_table).decode(num_distance_codes)
    @distance_table = HuffmanTable.new(distance_codes)
  end
end