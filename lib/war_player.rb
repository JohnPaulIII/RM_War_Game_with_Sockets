 
class WarPlayer
  
  attr_accessor :name, :hand

  def initialize(name)
    @name = name
    @hand = []
  end

  def take_card(*cards)
    Array(cards).each { |card| hand.unshift(card) }
  end

  def play_card
    hand.pop
  end

  def shuffle
    hand.shuffle!
  end

  def card_count
    hand.length
  end

  def out?
    hand.length == 0
  end

end

