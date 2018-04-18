class HuffmanTable
  attr_reader :codeword_lengths, :decoding_table, :encoding_table

  def initialize(codeword_lengths)
    @codeword_lengths = codeword_lengths
  end

  def decode(bitstream)
    load_table_if_needed

    bits = bitstream.read(@shortest_codeword_length)

    until @decoding_table.key?(bits.join)
      raise "Codeword not in table" if bits.size >= @longest_codeword_length
      bits += bitstream.read(1)
    end

    @decoding_table[bits.join]
  end

  def encode(symbols, bitstream)
    load_table_if_needed

    symbols.each do |symbol|
      bitstream.write(@encoding_table[symbol].chars.map(&:to_i))
    end

    bitstream.flush
  end

  private

  def load_table_if_needed
    return if @decoding_table

    @decoding_table = load_table
    @encoding_table = @decoding_table.invert
  end

  def load_table
    @shortest_codeword_length = @codeword_lengths.compact.min
    @longest_codeword_length = @codeword_lengths.compact.max
    lengths_indices = @codeword_lengths.zip(0...@codeword_lengths.size)
    valid_lengths_indices = lengths_indices.select { |(length, index)| length }
    table = {}
    current_value = 0
    current_codeword_length = @shortest_codeword_length
    valid_lengths_indices.sort.each do |(codeword_length, meaning)|
      if codeword_length > current_codeword_length
        length_difference = codeword_length - current_codeword_length
        current_value = current_value << length_difference
        current_codeword_length = codeword_length
      end

      table[current_value.to_s(2).rjust(current_codeword_length, "0")] = meaning
      current_value += 1
    end

    table
  end
end