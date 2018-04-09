class LengthDecoder
  def initialize(bitstream)
    @bitstream = bitstream
  end

  def decode(symbol)
    if 257 <= symbol && symbol <= 264
      3 + symbol - 257
    elsif 265 <= symbol && symbol <= 268
      11 + (symbol - 265) * 2 + @bitstream.bits_to_number(@bitstream.read(1))
    elsif 269 <= symbol && symbol <= 272
      19 + (symbol - 269) * 4 + @bitstream.bits_to_number(@bitstream.read(2))
    elsif 273 <= symbol && symbol <= 276
      35 + (symbol - 273) * 8 + @bitstream.bits_to_number(@bitstream.read(3))
    elsif 277 <= symbol && symbol <= 280
      67 + (symbol - 277) * 16 + @bitstream.bits_to_number(@bitstream.read(4))
    elsif 281 <= symbol && symbol <= 284
      131 + (symbol - 281) * 32 + @bitstream.bits_to_number(@bitstream.read(5))
    elsif 285 == symbol
      258
    else
      raise "Can't handle length symbol #{symbol}"
    end
  end
end