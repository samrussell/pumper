# sample huffman table from sample
# 35 90 C1 71 43 31 08 44 in file
# can parse as number 4408314371C19035
# first bit = 1 = last block
# next 2 bits = 10 = 2 = dynamic code
# next 5 bits = 00110 = 6, 6 + 257 = 263 literal/length codes
# next 5 bits = 10000 = 16, 16 + 1 = 17 distance codes
# next 4 bits = 1100 = 12, 12 + 4 = 16 code length codes
# code lengths array gets filled in the following order:
# 16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15
# we have 16 code length codes, each is 3 bits long, so pull the next 16 * 3 = 48 bits
# [
#   [0, 0, 0], [0, 0, 1], [1, 1, 0], [0, 0, 1],
#   [1, 1, 0], [1, 1, 0], [0, 0, 0], [1, 0, 1],
#   [0, 0, 0], [1, 1, 0], [0, 0, 0], [0, 1, 0],
#   [0, 0, 0], [0, 0, 1], [0, 0, 0], [1, 0, 1]
# ]
# this equals [0, 4, 3, 4, 3, 3, 0, 5, 0, 3, 0, 2, 0, 4, 0, 5]
# this goes into an array as follows:
# lengths.zip(aaa).each.with_object({}) { |(key, val), h| h[key] = val }
# {
#   16=>0, 17=>4, 18=>3, 0=>4,
#   8=>3, 7=>3, 9=>0, 6=>5,
#   10=>0, 5=>3, 11=>0, 4=>2,
#   12=>0, 3=>4, 13=>0, 2=>5,
#   14=>nil, 1=>nil, 15=>nil
# }
# put it in order
# {
#   0=>4,
#   1=>nil,
#   2=>5,
#   3=>4,
#   4=>2,
#   5=>3,
#   6=>5,
#   7=>3,
#   8=>3,
#   9=>0,
#   10=>0,
#   11=>0,
#   12=>0,
#   13=>0,
#   14=>nil,
#   15=>nil,
#   16=>0,
#   17=>4,
#   18=>3
# }
# we then build a huffman code out of this
# remove the zeroes
# {
#   0=>4,
#   2=>5,
#   3=>4,
#   4=>2,
#   5=>3,
#   6=>5,
#   7=>3,
#   8=>3,
#   17=>4,
#   18=>3
# }
# then sort by length
# {
#   4=>2,
#   5=>3,
#   7=>3,
#   8=>3,
#   18=>3,
#   0=>4,
#   3=>4,
#   17=>4,
#   2=>5,
#   6=>5,
# }
# then build codes
# {
#   4=>"00",
#   5=>"010",
#   7=>"011",
#   8=>"100",
#   18=>"101",
#   0=>"1100",
#   3=>"1101",
#   17=>"1110",
#   2=>"11110",
#   6=>"11111",
# }
# now let's build the literal/length codes, all 263 of them
# 
