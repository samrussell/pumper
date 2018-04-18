class Node
  include Comparable

  attr_reader :count
  attr_reader :symbol
  attr_reader :children

  def initialize(count, symbol: nil, children: [])
    @count = count
    @symbol = symbol
    @children = children
  end

  def <=>(other)
    @count <=> other.count
  end

  def to_s
    "Node<#{@count} #{@symbol} #{@children.to_s}>"
  end
end

class BuildHuffmanTable
  def initialize(symbol_counts)
    @symbol_counts = symbol_counts
  end

  def build
    @nodes = @symbol_counts.each.with_index.reject { |count, symbol| count.zero? }
      .map { |count, symbol| Node.new(count, symbol: symbol) }
    @num_symbols = @symbol_counts.length

    while @nodes.length > 2
      @nodes = @nodes.sort
      children = [@nodes.shift, @nodes.shift]
      @nodes.push(Node.new(children.reduce(0){|sum, node| sum + node.count}, children: children))
    end

    self
  end

  def codeword_lengths
    return @codeword_lengths unless @codeword_lengths.nil?

    # traverse the tree
    @codeword_lengths = {}

    # popoulate with nils
    @num_symbols.times.each { |symbol| @codeword_lengths[symbol] = nil }

    @nodes.each { |node| traverse_codewords(node, 1) }

    @codeword_lengths.sort.map { |(symbol, length)| length }
  end

  def traverse_codewords(node, depth)
    if node.symbol
      @codeword_lengths[node.symbol] = depth
    elsif !node.children.empty?
      node.children.each { |node| traverse_codewords(node, depth+1) }
    end
  end
end