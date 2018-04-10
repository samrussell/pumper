class LengthDecoder
  def initialize(bitstream)
    @bitstream = bitstream
  end

  def decode(symbol)
    if 257 <= symbol && symbol <= 264
      3 + symbol - 257
    elsif 265 <= symbol && symbol <= 284
      num_bits = (symbol-261) / 4
      offset = (symbol-261) % 4
      3 + (4 << num_bits) + (offset << num_bits) + @bitstream.read_number(num_bits)
    elsif 285 == symbol
      258
    else
      raise "Can't handle length symbol #{symbol}"
    end
  end
end