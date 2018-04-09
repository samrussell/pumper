require "./lib/bitstream.rb"
require "./lib/huffman_table.rb"
require "./lib/length_decoder.rb"
require "./lib/distance_decoder.rb"

class Unhuffer
  FIXED_HUFFMAN_CODES = 1
  DYNAMIC_HUFFMAN_CODES = 2
  CODE_LENGTHS_ARRAY = [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15]

  def initialize(block_file)
    @block_file = block_file
  end

  def data
    @bitstream = Bitstream.new(@block_file)
    final_flag = @bitstream.read(1)
    encoding_type = @bitstream.bits_to_number(@bitstream.read(2))
    raise "Can only handle dynamic codes" unless encoding_type == DYNAMIC_HUFFMAN_CODES

    build_huffman_tables

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

        length.times.each do
          symbols.push(symbols[-distance])
        end
      end
    end

    symbols.map(&:chr).join
  end

  private

  def build_huffman_tables
    num_literal_length_codes = 257 + @bitstream.bits_to_number(@bitstream.read(5))
    num_distance_codes = 1 + @bitstream.bits_to_number(@bitstream.read(5))
    num_code_length_codes = 4 + @bitstream.bits_to_number(@bitstream.read(4))
    unsorted_code_length_codes = num_code_length_codes.times.map { @bitstream.bits_to_number(@bitstream.read(3)) }
    code_lengths_dictionary = CODE_LENGTHS_ARRAY.zip(unsorted_code_length_codes).each.with_object({}) do |(code, length), hash|
      if length && length > 0
        hash[code] = length
      else
        hash[code] = nil
      end
    end
    code_lengths = code_lengths_dictionary.sort.map {|x| x[1]}

    code_length_table = HuffmanTable.new(code_lengths)

    # there's a nicer lazy enumerable way of doing this
    # we're going to do it the ugly way for now and refactor later
    literal_length_codes = []
    while literal_length_codes.size < num_literal_length_codes
      code = code_length_table.decode(@bitstream)
      if code == 0
        literal_length_codes.push(nil)
      elsif code < 16
        literal_length_codes.push(code)
      elsif code == 16
        # copy the previous code 3-6 times based on next 2 bits
        num_copies = 3 + @bitstream.bits_to_number(@bitstream.read(2))
        last_code = literal_length_codes.last
        num_copies.times.each { literal_length_codes.push(last_code) }
      elsif code == 17
        # add 3-10 0's based on the next 3 bits
        num_copies = 3 + @bitstream.bits_to_number(@bitstream.read(3))
        num_copies.times.each { literal_length_codes.push(nil) }
      elsif code == 18
        # add 11-138 0's based on the next 7 bits
        num_copies = 11 + @bitstream.bits_to_number(@bitstream.read(7))
        num_copies.times.each { literal_length_codes.push(nil) }
      end
    end

    @literal_length_table = HuffmanTable.new(literal_length_codes)

    # see we're even duplicating code here, so an obvious abstraction to pull out
    distance_codes = []
    while distance_codes.size < num_distance_codes
      code = code_length_table.decode(@bitstream)
      if code == 0
        distance_codes.push(nil)
      elsif code < 16
        distance_codes.push(code)
      elsif code == 16
        # copy the previous code 3-6 times based on next 2 bits
        num_copies = 3 + @bitstream.bits_to_number(@bitstream.read(2))
        last_code = distance_codes.last
        num_copies.times.each { distance_codes.push(last_code) }
      elsif code == 17
        # add 3-10 0's based on the next 3 bits
        num_copies = 3 + @bitstream.bits_to_number(@bitstream.read(3))
        num_copies.times.each { distance_codes.push(nil) }
      elsif code == 18
        # add 11-138 0's based on the next 7 bits
        num_copies = 11 + @bitstream.bits_to_number(@bitstream.read(7))
        num_copies.times.each { distance_codes.push(nil) }
      end
    end

    @distance_table = HuffmanTable.new(distance_codes)
  end
end