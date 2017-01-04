require 'pry'

VALUES = ['2', '3', '4', '5', '6', '7', '8', '9',
          '10', 'J', 'Q', 'K', 'A'].freeze
SUITS = ['H', 'S', 'C', 'D'].freeze

TARGET = 21
DEALER_NO = 17

HIT_OR_STAY_PROMPT = "Would you like to (h)it or (s)tay?".freeze
PLAY_AGAIN_PROMPT = "Would you like to play again? (y or n)".freeze
INVALID_ANSWER_PROMPT = "Sorry, that's not a valid answer.".freeze

PLAYERS = ['Player', 'Dealer'].freeze

def prompt(msg)
  puts "=> #{msg}"
end

def validate_answer(question, valid_answers)
  answer = ''
  loop do
    prompt question
    answer = gets.chomp.downcase
    break if valid_answers.include?(answer)
    prompt INVALID_ANSWER_PROMPT
  end
  answer
end

def initialize_deck
  SUITS.product(VALUES).shuffle
end

def deal_cards!(deck, player_cards, dealer_cards)
  2.times do
    player_cards << deck.pop
    dealer_cards << deck.pop
  end
end

def display_initial_deal(player_cards, dealer_cards)
  prompt "You have: #{player_cards[0]} and #{player_cards[1]}"\
       " for a total of #{total(player_cards)}"
  prompt "Dealer has: #{dealer_cards[0]} and ?"
end

def total(cards)
  sum = 0
  # cards: [["H", "10"], ["D", "3"]]
  cards.each do |card|
    sum += if card.last == 'A'
             11
           elsif card.last.to_i.zero?
             10
           else
             card.last.to_i
           end
  end

  # correct for aces
  aces = cards.select { |card| card.include?('A') }
  aces.length.times { |_| sum -= 10 if sum > 21 }

  sum
end

def hit!(deck, cards)
  cards << deck.pop
end

def busted?(cards)
  total(cards) > 21
end

def player_does_turn(deck, player_cards)
  loop do
    answer = validate_answer(HIT_OR_STAY_PROMPT, ['h', 's'])
    if answer == 'h'
      hit!(deck, player_cards)
      prompt "You hit!"
      prompt "You have: #{cards} for a total of #{total(cards)}"
    end

    break if busted?(player_cards) || answer == 's'
  end
end

def dealer_does_turn(deck, dealer_cards)
  loop do
    break if total(dealer_cards) >= 17
    hit!(deck, dealer_cards)
    prompt "Dealer hit!"
    prompt "Dealer has: #{dealer_cards} for a total of #{total(dealer_cards)}"
  end
end

def display_final_cards(player_cards, dealer_cards)
  prompt "You have: #{player_cards} for a total of #{total(player_cards)}"
  prompt "Dealer has: #{dealer_cards} for a total of #{total(dealer_cards)}"
end

def display_busted_result(loser, player_cards, dealer_cards)
  winner = PLAYERS.select { |player| player != loser }.first
  prompt "#{loser == 'Player' ? 'You' : 'Dealer'} busted!"
  display_final_cards(player_cards, dealer_cards)
  prompt "#{winner == 'Player' ? 'You' : 'Dealer'} won!"
end

def detect_result(player_cards, dealer_cards)
  player_total = total(player_cards)
  dealer_total = total(dealer_cards)

  if player_total > dealer_total
    :player
  elsif dealer_total > player_total
    :dealer
  else
    :tie
  end
end

def display_result(player_cards, dealer_cards)
  display_final_cards(player_cards, dealer_cards)
  result = detect_result(player_cards, dealer_cards)
  case result
  when :player then prompt "You win!"
  when :dealer then prompt "Dealer wins!"
  when :tie then prompt "It's a tie!"
  end
end

def play_again?(answer)
  answer == 'y'
end

loop do
  deck = initialize_deck
  player_cards = []
  dealer_cards = []

  deal_cards!(deck, player_cards, dealer_cards)
  display_initial_deal(player_cards, dealer_cards)

  player_does_turn(deck, player_cards)

  if busted?(player_cards)
    display_busted_result('Player', player_cards, dealer_cards)

    answer = validate_answer(PLAY_AGAIN_PROMPT, ['y', 'n'])
    play_again?(answer) ? next : break
  end

  prompt "You stayed."
  prompt "Dealer turn..."

  dealer_does_turn(deck, dealer_cards)

  if busted?(dealer_cards)
    display_busted_result('Dealer', player_cards, dealer_cards)

    answer = validate_answer(PLAY_AGAIN_PROMPT, ['y', 'n'])
    play_again?(answer) ? next : break
  end

  prompt "Dealer stayed."
  display_result(player_cards, dealer_cards)

  answer = validate_answer(PLAY_AGAIN_PROMPT, ['y', 'n'])
  break unless play_again?(answer)
end
