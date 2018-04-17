# Pumper
This is a minimal implementation of `gunzip` to illustrate compression with LZ77 and Huffman codes and their combination in the DEFLATE algorithm.

The official source of truth for this is in the RFC at https://tools.ietf.org/html/rfc1951

## LZ77

This works on the assumption that most files repeat things from time to time. For example, the sentence "The cat sat on a mat on a towel." has a lot of repetitions:

- We use "on a" twice (with spaces either side)
- There are a few words that end in "at" (with a space afterwards)

We can refer to these using a tuple of <length, backward distance> and save a few characters every time we get a repetition. In LZ77 it's not worth encoding any less than 3 characters, so we'll only store tuples where the length is 3 or more.

We can encode the above sentence in LZ77 as follows:

"The cat s<3,4>on a m<3,9><5,9>towel."

The space at the end of "mat " competes with the space at the start of " on a " so you might also encode it like this:

"The cat s<3,4>on a mat<6,8>towel."

Both of these decode to the same input, but different algorithms give us different amounts of compression. I've implemented the greedy algorithm here, feel free to explore other options.

## Huffman coding

Most of the information we store on a computer is packed into 8-bit bytes, which can be any value from 0 to 255. In practice, we don't use most of the values - this file probably only uses around 60 of them - less than a quarter! In addition to that, I'm using mainly lowercase characters, whitespace characters, and a bit of punctuation, (about 30 characters), and even then, English uses some characters (vowels and popular consonants) way more than others.

Huffman coding allows us to store data based on how often it is used. Instead of using 8 bits for every possible character when we aren't using 75% of them, we can use less bits to encode common characters (so maybe vowels will only take 2-3 bits), and more bits to encode uncommon characters (capital letters and uncommon consonants), and giving up the space used by the other 190 symbols that you can technically print in a byte but aren't used in this file at all.

This is called Entropy Coding, and combined with LZ77, we get the DEFLATE compression scheme. Huffman coding can't take advantage of the fact that we've used the string "Huffman cod" 5 times in this file (including here), and LZ77 can't tell that we're wasting roughly half of our bits on the off chance that we might want to print a crazy ASCII character (which we won't do here).

There's one more thing we need to glue it together - distance and length coding

## LZ77 distance and length coding

You might have noticed that the string <3,4> takes more than 3 characters, but only compresses a 3 character string. You might say "that's not compression, that's actually the opposite of compression", and you'd be right. The way DEFLATE works around this is by taking the 0-255 combinations you can fit in a byte, and adding another 30 combinations as follows:

| Codeword  | Literal / length | Extra bits |
| --------- | ---------------- | ---------- |
| 0         | 0                | N/A        |
| 1         | 1                | N/A        |
| .         | .                | .          |
| .         | .                | .          |
| 254       | 254              | N/A        |
| 255       | 255              | N/A        |
| 256       | End of block     | N/A        |
| 257       | Length = 3       | 0          |
| 258       | Length = 4       | 0          |
| 259       | Length = 5       | 0          |
| 260       | Length = 6       | 0          |
| 261       | Length = 7       | 0          |
| 262       | Length = 8       | 0          |
| 263       | Length = 9       | 0          |
| 264       | Length = 10      | 0          |
| 265       | Length = 11,12   | 1          |
| 266       | Length = 13,14   | 1          |
| 267       | Length = 15,16   | 1          |
| 268       | Length = 17,18   | 1          |
| 269       | Length = 19-22   | 2          |
| 270       | Length = 23-26   | 2          |
| 271       | Length = 27-30   | 2          |
| 272       | Length = 31-34   | 2          |
| 273       | Length = 35-42   | 3          |
| 274       | Length = 43-50   | 3          |
| 275       | Length = 51-58   | 3          |
| 276       | Length = 59-66   | 3          |
| 277       | Length = 67-82   | 4          |
| 278       | Length = 83-98   | 4          |
| 279       | Length = 99-114  | 4          |
| 280       | Length = 115-130 | 4          |
| 281       | Length = 131-162 | 5          |
| 282       | Length = 163-194 | 5          |
| 283       | Length = 195-226 | 5          |
| 284       | Length = 227-257 | 5          |
| 285       | Length = 258     | 0          |

If we get a number in the range 0-255 we just copy it as-is, but if we get a length code, we read as many bits as we need to, and then read the coded distance value and decode in a similar fashion:

| Codeword | Distance    | Extra bits  |
| -------- | ----------- | ----------- |
| 0        |       1     | 0           |
| 1        |       2     | 0           |
| 2        |       3     | 0           |
| 3        |       4     | 0           |
| 4        |      5,6    | 1           |
| 5        |      7,8    | 1           |
| 6        |      9-12   | 2           |
| 7        |     13-16   | 2           |
| 8        |     17-24   | 3           |
| 9        |     25-32   | 3           |
| 10       |     33-48   | 4           |
| 11       |     49-64   | 4           |
| 12       |     65-96   | 5           |
| 13       |     97-128  | 5           |
| 14       |    129-192  | 6           |
| 15       |    193-256  | 6           |
| 16       |    257-384  | 7           |
| 17       |    385-512  | 7           |
| 18       |    513-768  | 8           |
| 19       |   769-1024  | 8           |
| 20       |   1025-1536 | 9           |
| 21       |   1537-2048 | 9           |
| 22       |   2049-3072 | 10          |
| 23       |   3073-4096 | 10          |
| 24       |   4097-6144 | 11          |
| 25       |   6145-8192 | 11          |
| 26       |  8193-12288 | 12          |
| 27       | 12289-16384 | 12          |
| 28       | 16385-24576 | 13          |
| 29       | 24577-32768 | 13          |

So our example case of "The cat s<3,4>" encodes as ("The cat s<257><3>"), and this now lets us use Huffman coding to shrink things down.

## The Huffman coders

So it turns out we actually need 3 Huffman coders for this. The main one encodes what the RFC calls the "literal/length values" - the numbers from 0-285 that are sometimes literal characters and sometimes the start of a length,distance pair.

The second coder is for the distance values. The codewords range from 0-29, meaning we need 5 bits to store them, but we can shrink that down further - for example, if our distances are normally less than 16, then we only need codewords 0-7, and the most popular codewords will take up even less room.

So what's the third Huffman coder for?

Coding the first 2 Huffman tables of course!

### More to come

You can stop here if you like and start playing with the code. The part that encodes the encoders is BuildHuffmanTables, and it's good to see it in practice, but the important concepts are in the LZ77Decoder and HuffmanTable classes. The unit tests should give you a basic idea of how we're shrinking things down in size, and of course you can always drop in a byebug and see what's going on.

The samples folder has the Lorem Ipsum text as is and compressed with gzip, and unpack.rb should be able to decompress it for you - feel free to follow along and see what it does along the way. It gets a little convoluted building a Huffman table to decode the other Huffman tables, but once you've got them all set up the final decompression stage is pretty straightforward.
