class CodeLengthDecoder
  def initialize(bitstream, code_length_table)
    @bitstream = bitstream
    @code_length_table = code_length_table
  end

  def decode(num_codes)
    codes = []
    while codes.size < num_codes
      code = @code_length_table.decode(@bitstream)
      if code == 0
        codes.push(nil)
      elsif code < 16
        codes.push(code)
      elsif code == 16
        # copy the previous code 3-6 times based on next 2 bits
        num_copies = 3 + @bitstream.read_number(2)
        last_code = codes.last
        num_copies.times.each { codes.push(last_code) }
      elsif code == 17
        # add 3-10 0's based on the next 3 bits
        num_copies = 3 + @bitstream.read_number(3)
        num_copies.times.each { codes.push(nil) }
      elsif code == 18
        # add 11-138 0's based on the next 7 bits
        num_copies = 11 + @bitstream.read_number(7)
        num_copies.times.each { codes.push(nil) }
      end
    end

    codes
  end 
end