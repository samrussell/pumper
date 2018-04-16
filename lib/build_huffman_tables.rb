require "./lib/huffman_table.rb"
require "./lib/code_length_decoder.rb"

class BuildHuffmanTables
  CODE_LENGTHS_ARRAY = [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15]
  MINIMUM_LITERAL_LENGTH_CODES = 257
  MINIMUM_DISTANCE_CODES = 1
  MINIMUM_CODE_LENGTH_CODES = 4

  def initialize(bitstream)
    @bitstream = bitstream
  end

  def distance_table
    build_huffman_tables unless @distance_table

    @distance_table
  end

  def literal_length_table
    build_huffman_tables unless @literal_length_table

    @literal_length_table
  end

  private

  def build_huffman_tables
    num_literal_length_codes = MINIMUM_LITERAL_LENGTH_CODES + @bitstream.read_number(5)
    num_distance_codes = MINIMUM_DISTANCE_CODES + @bitstream.read_number(5)
    num_code_length_codes = MINIMUM_CODE_LENGTH_CODES + @bitstream.read_number(4)

    @code_length_table = build_code_length_table(num_code_length_codes)
    @literal_length_table = build_literal_length_table(num_literal_length_codes)
    @distance_table = build_distance_table(num_distance_codes)
  end

  def build_code_length_table(num_code_length_codes)
    unsorted_code_length_codes = num_code_length_codes.times.map { @bitstream.read_number(3) }
    code_lengths_dictionary = CODE_LENGTHS_ARRAY.zip(unsorted_code_length_codes).each.with_object({}) do |(code, length), hash|
      if length && length > 0
        hash[code] = length
      else
        hash[code] = nil
      end
    end

    code_lengths = code_lengths_dictionary.sort.map {|x| x[1]}

    HuffmanTable.new(code_lengths)
  end

  def build_literal_length_table(num_literal_length_codes)
    literal_length_codes = CodeLengthDecoder.new(@bitstream, @code_length_table).decode(num_literal_length_codes)

    HuffmanTable.new(literal_length_codes)
  end

  def build_distance_table(num_distance_codes)
    distance_codes = CodeLengthDecoder.new(@bitstream, @code_length_table).decode(num_distance_codes)

    HuffmanTable.new(distance_codes)
  end
end