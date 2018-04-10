class DistanceDecoder
  def initialize(bitstream)
    @bitstream = bitstream
  end

  def decode(symbol)
    if 0 <= symbol && symbol <= 3
      1 + symbol
    elsif 4 <= symbol && symbol <= 29
      num_bits = (symbol-2) / 2
      offset = (symbol-2) % 2
      1 + (2 << num_bits) + (offset << num_bits) + @bitstream.read_number(num_bits)
    else
      raise "Can't handle length symbol #{symbol}"
    end
  end
end