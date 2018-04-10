require "./lib/bitstream.rb"
require "./lib/huffman_table.rb"
require "./lib/length_decoder.rb"
require "./lib/distance_decoder.rb"
require "./lib/code_length_decoder.rb"

class Unhuffer
  FIXED_HUFFMAN_CODES = 1
  DYNAMIC_HUFFMAN_CODES = 2
  CODE_LENGTHS_ARRAY = [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15]

  def initialize(block_file)
    @block_file = block_file
  end

  def data
    @bitstream = Bitstream.new(@block_file)

    read_header

    build_huffman_tables

    lz77_encoded_data = decode_huffman

    symbols = decode_lz77(lz77_encoded_data)

    symbols.map(&:chr).join
  end

  private

  def decode_huffman
    length_decoder = LengthDecoder.new(@bitstream)
    distance_decoder = DistanceDecoder.new(@bitstream)

    symbols = []
    while true
      symbol = @literal_length_table.decode(@bitstream)
      break if symbol == 256
      if symbol < 256
        symbols.push(symbol)
      else
        length = length_decoder.decode(symbol)
        distance_prefix = @distance_table.decode(@bitstream)
        distance = distance_decoder.decode(distance_prefix)

        symbols.push([distance, length])
      end
    end

    symbols
  end

  def decode_lz77(encoded_data)
    decoded_data = []
    encoded_data.each do |literal_or_copy|
      if literal_or_copy.is_a?(Fixnum)
        decoded_data.push(literal_or_copy)
      else
        distance, length = literal_or_copy
        length.times.each do
          decoded_data.push(decoded_data[-distance])
        end
      end
    end

    decoded_data
  end

  def read_header
    final_flag = @bitstream.read(1)
    encoding_type = @bitstream.read_number(2)
    raise "Can only handle dynamic codes" unless encoding_type == DYNAMIC_HUFFMAN_CODES
  end

  def build_huffman_tables
    num_literal_length_codes = 257 + @bitstream.read_number(5)
    num_distance_codes = 1 + @bitstream.read_number(5)
    num_code_length_codes = 4 + @bitstream.read_number(4)
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