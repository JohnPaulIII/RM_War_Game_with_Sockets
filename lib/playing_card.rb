class PlayingCard
  RANKS = %w( 2 3 4 5 6 7 8 9 10 J Q K A )
  #RANKS = %w( 9 10 J Q K A )
  SUITES = %w( Clubs Diamonds Hearts Spades )
  #SUITES = %w( Clubs Diamonds )

  attr_accessor :rank, :suit

  def initialize(rank, suit)
    @rank = RANKS.include?(rank) ? rank : ''
    @suit = SUITES.include?(suit) ? suit : ''
  end

  def ==(other)
    rank == other.rank && suit == other.suit
  end

  def eql_rank?(other)
    return unless other.respond_to?(:rank)
    rank == other.rank
  end

  def >(other)
    return true unless other.respond_to?(:rank)
    RANKS.index(rank) > RANKS.index(other.rank)
  end

  def <(other)
    return unless other.respond_to?(:rank)
    RANKS.index(rank) < RANKS.index(other.rank)
  end

end
