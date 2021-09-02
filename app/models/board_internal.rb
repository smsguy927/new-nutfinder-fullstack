# frozen_string_literal: true
require_relative './card_internal'


class BoardInternal
  attr_reader :cards, :sorted_cards, :nut_combos, :nut_board, :one_card_nuts, :flush_suit, :rank_counts, :pair_type,
              :nut_type, :sf_type, :sf_pair_type, :sf_alt_nuts, :gap_ranks, :straight_type, :sf_straight_ranks,
              :compound_sf_ranks, :compound_sf_gaps, :compound_sf_gap_sizes, :consecutive_gap_sizes

  BOARD_SIZE = 5
  QUADS_COUNTS_SIZE = 2
  QUADS_COUNT = 4
  PAIR_COUNT = 2
  TRIPS_COUNT = 3
  FIRST_CARD_INDEX = 0
  SECOND_CARD_INDEX = 1
  MIDDLE_CARD_INDEX = 2
  FOURTH_CARD_INDEX = 3
  LAST_CARD_INDEX = 4
  ONE_CARD_NUT_SF_COUNT = 4
  ONE_CARD_FLUSH_COUNT = 4
  ONE_CARD_STRAIGHT_COUNT = 4
  MAX_GAPS_SF_STRAIGHT = 2
  MAX_GAPS_ONE_CARD_SF = 2
  MIN_RANKS_SF_STRAIGHT = 3
  FLUSH_RANKS_OFFSET = 2
  ANY_RANK = 'X'
  ANY_SUIT = 'x'
  CARD_SEP = '_'
  COMBO_SEP = '__'

  SF_TYPES = {
    ZERO_GAPS: 0,
    ONE_GAP: 1,
    TWO_GAPS: 2,
    ONE_CARD: 3,
    ONE_CARD_SW: 4,
    STEEL_WHEEL: 5,
    ROYAL_FLUSH: 6,
    RF_STEEL: 7,
    KQJ: 8,
    FOUR_THREE_TWO: 9,
    COMPOUND: 10
  }.freeze

  NUT_TYPES = {
    NUT_BOARD: 0,
    ONE_CARD_SF: 1,
    STRAIGHT_FLUSH: 2,
    ONE_CARD_QUADS: 3,
    BOARD_QUADS: 4,
    QUADS_FULL_HOUSE: 5,
    TOP_FULL_HOUSE: 6,
    ONE_CARD_FLUSH: 7,
    FLUSH: 8,
    ONE_CARD_STRAIGHT: 9,
    STRAIGHT: 10,
    SET: 11
  }.freeze

  PAIR_TYPES = {
    NO_PAIR: -1,
    PAIR_FIRST_CARD: 0,
    PAIR_SECOND_CARD: 2,
    PAIR_THIRD_CARD: 3,
    PAIR_FOURTH_CARD: 4,
    TWO_PAIR_KICK_FIRST: 5,
    TWO_PAIR_KICK_SECOND: 6,
    TWO_PAIR_KICK_THIRD: 7,
    TRIPS_FIRST_CARD: 8,
    TRIPS_SECOND_CARD: 9,
    TRIPS_THIRD_CARD: 10,
    TRIPS_FOURTH_CARD: 11,
    FULL_HOUSE_TRIPS_HIGH: 12,
    FULL_HOUSE_TRIPS_LOW: 13,
    QUADS: 14,
    QUAD_ACES: 15
  }.freeze

  SF_PAIR_TYPES = {
    TRIPS: 0,
    TOP_PAIRED_NEXT_GAP: 1,
    PAIR_IN_GAP: 2,
    FIVES_ON_432: 3,
    TENS_ON_KQJ: 4,
    OTHER_PAIRED: 5
  }.freeze

  STRAIGHT_TYPES = {
    ZERO_GAPS: 0,
    ONE_GAP: 1,
    TWO_GAPS: 2,
    WHEEL: 3,
    BROADWAY: 4
  }.freeze

  RANKS = %w[A K Q J T 9 8 7 6 5 4 3 2].freeze

  def initialize
    @cards = []
    @sorted_cards = []
    @nut_combos = []
    @compound_sf_ranks = []
    @compound_sf_gaps = []
    @compound_sf_gap_sizes = []
    @consecutive_gap_sizes = []
    @nut_board = false
  end



  def make_board_with(arr)
    ranks = %w[x x 2 3 4 5 6 7 8 9 T J Q K A]
    arr.each do |i|
      new_card = {}
      new_card[:rank_id] = ranks.index(i[0].upcase)
      new_card[:rank] = i[0].upcase
      new_card[:suit] = i[1].downcase
      @cards.push(CardInternal.new(new_card))
      @sorted_cards.push(CardInternal.new(new_card))
    end
    set_board_attributes
  end

  def display
    cards.map{|card|"#{card.rank}#{card.suit}"}.join(' ')
  end

  private

  def sort
    sorted_cards.sort! { |first, second| second <=> first }
  end

  def set_board_attributes
    sort
    set_flush_suit
    set_nut_board
    set_sf_types
    set_nut_type
    set_nut_combos
  end

  def set_flush_suit
    suit_counts = { c: 0, d: 0, h: 0, s: 0 }
    min_suit_count = 3
    sorted_cards.each do |card|
      suit_counts[card.suit.to_sym] += 1
    end
    suit_counts.filter! { |_key, val| val >= min_suit_count }
    @flush_suit = suit_counts.keys[0].to_s unless suit_counts.empty?
  end

  def set_nut_board
    set_rank_counts
    @nut_board = true if royal_flush_board?
    @nut_board = true if nut_quads_board?
    @nut_board = true if no_flush_broadway_board?
  end

  def set_rank_counts
    rank_counts = {}
    cards.each do |card|
      if rank_counts[card.rank].nil?
        rank_counts[card.rank]  = 1
      else
        rank_counts[card.rank] += 1
      end
    end
    @rank_counts = rank_counts
  end

  def broadway_card?(str)
    broadway_ranks = %w[A K Q J T]
    broadway_ranks.include?(str)
  end

  def wheel_card?(str)
    wheel_ranks = %w[2 3 4 5 A]
    wheel_ranks.include?(str)
  end

  def royal_flush_board?
    @rank_counts.size == BOARD_SIZE && cards.all?(&:broadway_card?) && cards.all? { |card| card.suit == flush_suit }
  end

  def nut_quads_board?
    board_quads? && board_quads_ace? || board_quad_aces_king?
  end

  def board_quads?
    @rank_counts.any? { |rank| rank[1] == QUADS_COUNT }
  end

  def board_quads_ace?
    @rank_counts['A'] == 1
  end

  def board_quad_aces?
    @rank_counts['A'] == QUADS_COUNT
  end

  def board_quad_aces_king?
    board_quad_aces? && @rank_counts['K'] == 1
  end

  def no_flush_broadway_board?
    flush_suit.nil? && rank_counts.size == BOARD_SIZE && cards.all?(&:broadway_card?)
  end

  def set_sf_types
    return if flush_suit.nil?

    set_sf_type
    set_sf_alt_nuts if !sf_type.nil? && sf_type >= SF_TYPES[:ONE_GAP]
  end

  def board_paired?
    @rank_counts.any? { |rank| rank[1] >= PAIR_COUNT }
  end

  def three_consecutive_sf_cards?(sf_ranks)
    i = 0
    i += 1 while sf_ranks[i] == 'A'
    current_rank = sf_ranks[i]
    current_ranks_table_index = RANKS.index(current_rank)
    new_sf_ranks = []
    while i < sf_ranks.size
      if current_ranks_table_index == RANKS.index(current_rank)
        new_sf_ranks.push(current_rank)
        break if new_sf_ranks.size >= MIN_RANKS_SF_STRAIGHT

        current_ranks_table_index += 1
      else
        new_sf_ranks.clear
        current_ranks_table_index = RANKS.index(sf_ranks[i])
        next
      end
      i += 1
      current_rank = sf_ranks[i]
    end
    if new_sf_ranks.size >= MIN_RANKS_SF_STRAIGHT
      set_sf_straight_ranks(new_sf_ranks)
      true
    else
      false
    end
  end

  def set_steel_wheel(sf_ranks)
    filtered_ranks = find_wheel_ranks(sf_ranks)
    if filtered_ranks.size >= MIN_RANKS_SF_STRAIGHT
      sw_gaps = find_sw_gaps(filtered_ranks)
      set_gaps(sw_gaps)
      @sf_type = SF_TYPES[:STEEL_WHEEL]
    end
  end

  def set_wheel(board_ranks)
    filtered_ranks = find_wheel_ranks(board_ranks)
    if filtered_ranks.size >= MIN_RANKS_SF_STRAIGHT
      wheel_gaps = find_wheel_gaps(filtered_ranks)
      set_gaps(wheel_gaps)
      @straight_type = STRAIGHT_TYPES[:WHEEL]
    end
  end

  def find_broadway_ranks(sf_ranks)
    sf_ranks.filter { |rank| broadway_card?(rank) }
  end

  def find_broadway_ranks_from_cards
    sorted_cards.filter(&:broadway_card?).map(&:rank)
  end

  def find_rf_gaps(filtered_ranks)
    rf_ranks = %w[A K Q J T]
    rf_ranks.filter { |rank| !filtered_ranks.include?(rank) }
  end

  def set_royal_flush(sf_ranks)
    filtered_ranks = find_broadway_ranks(sf_ranks)
    rf_gaps = find_rf_gaps(filtered_ranks)
    set_gaps(rf_gaps)
  end

  def find_wheel_ranks(ranks)
    ranks.filter { |rank| wheel_card?(rank) }
  end

  def royal_flush?(sf_ranks)
    return false unless sf_ranks.include?('A')

    broadway_cards = sf_ranks.filter { |rank| broadway_card?(rank) }.size
    broadway_cards >= MIN_RANKS_SF_STRAIGHT
  end

  def royal_flush_steel_wheel?(sf_ranks)
    return false unless sf_ranks.include?('A')

    broadway_cards = sf_ranks.filter { |rank| broadway_card?(rank) }.size
    wheel_cards = sf_ranks.filter { |rank| wheel_card?(rank) }.size
    broadway_cards >= MIN_RANKS_SF_STRAIGHT && wheel_cards >= MIN_RANKS_SF_STRAIGHT
  end

  def kqj_straight_flush?(sf_ranks)
    sf_ranks.include?('K') && sf_ranks.include?('Q') && sf_ranks.include?('J')
  end

  def four_32_sf?(sf_ranks)
    sf_ranks.include?('4') && sf_ranks.include?('3') && sf_ranks.include?('2')
  end

  def set_three_consecutive_sf_type(sf_ranks)
    if kqj_straight_flush?(sf_ranks)
      SF_TYPES[:KQJ]
    elsif four_32_sf?(sf_ranks)
      SF_TYPES[:FOUR_THREE_TWO]
    else
      SF_TYPES[:ZERO_GAPS]
    end
  end

  def calc_gaps(rank, next_rank)
    (RANKS.index(rank) - RANKS.index(next_rank)).abs - 1
  end

  def shift_bad_ranks(sf_ranks, blockers, next_rank)
    i = 0
    test_rank = sf_ranks[1]
    while i < sf_ranks.size
      if calc_gaps(sf_ranks[0], test_rank) > MAX_GAPS_SF_STRAIGHT
        sf_ranks.shift
        blockers.shift while !blockers.empty? && RANKS.index(blockers[0]) <= RANKS.index(sf_ranks[0])
      end
      i += 1
      test_rank = i < sf_ranks.size - 1 ? sf_ranks[i + 1] : next_rank
    end
  end

  def set_rf_steel(flush_ranks)
    set_royal_flush(flush_ranks)
  end

  def set_compound_sf(flush_ranks)
    ranks_left = flush_ranks.size
    ranks_index = RANKS.index(flush_ranks[0])
    i = 0
    while i < flush_ranks.size - 1
      ranks_left -= 1
      next_rank = flush_ranks[i + 1]
      next_flush_ranks_index = RANKS.index(next_rank).nil? ? 0 : RANKS.index(next_rank)
      gap_size = next_flush_ranks_index - 1 - ranks_index
      @compound_sf_gap_sizes.push(gap_size)
      i += 1
      ranks_index = next_flush_ranks_index
    end
    i = 0
    while i < @compound_sf_gap_sizes.size - 1
      total_gap_sizes = @compound_sf_gap_sizes[i] + @compound_sf_gap_sizes[i + 1]
      @consecutive_gap_sizes.push(total_gap_sizes)
      i += 1
    end
    if consecutive_gap_sizes.size >= 2 && consecutive_gap_sizes[0].zero? && consecutive_gap_sizes[1] == 1
      three_consecutive_sf_cards?(flush_ranks)
      @sf_type = set_three_consecutive_sf_type(flush_ranks)
    elsif @consecutive_gap_sizes.filter(&:zero?).size > 1 || consecutive_gap_sizes.size >= 2 && consecutive_gap_sizes[1].zero? && consecutive_gap_sizes[0] == 1 || compound_sf_gap_sizes[0] == 0 && compound_sf_gap_sizes[1] == 1 && compound_sf_gap_sizes[2] == 0 || compound_sf_gap_sizes[1]== 0 && compound_sf_gap_sizes[2] == 1 && compound_sf_gap_sizes[3] == 0
      set_one_card_sf(flush_ranks)
    elsif @consecutive_gap_sizes.filter { |size| size <= MAX_GAPS_SF_STRAIGHT }.size > 1
      @sf_type = SF_TYPES[:COMPOUND]
      i = 0
      while i < @consecutive_gap_sizes.size
        if @consecutive_gap_sizes[i] <= MAX_GAPS_SF_STRAIGHT

          current_sf_ranks = flush_ranks[i..i + FLUSH_RANKS_OFFSET]
          current_sf_gaps = @compound_sf_gap_sizes[i..i + 1]
          set_sf_type_2(current_sf_ranks, current_sf_gaps)

        end
        i += 1
      end
    end
  end

  def set_compound_gaps(new_sf_blockers)
    @compound_sf_gaps.push(new_sf_blockers.join)
  end

  def set_compound_sf_straight_ranks(sf_ranks)
    @compound_sf_ranks.push(sf_ranks.join)
  end

  def set_sf_type_2(sf_ranks, sf_gaps)

    i = 0
    ranks_left = sf_ranks.size
    ranks_index = RANKS.index(sf_ranks[0])
    new_sf_blockers = []


    while i < ranks_left - 1
      next_rank = sf_ranks[i + 1]
      next_flush_ranks_index = RANKS.index(next_rank).nil? ? 0 : RANKS.index(next_rank)
      gap_size = sf_gaps[i]

      add_gaps(new_sf_blockers, gap_size, ranks_index + 1)


      i += 1
      ranks_index = next_flush_ranks_index
    end

    set_compound_gaps(new_sf_blockers)
    set_compound_sf_straight_ranks(sf_ranks)
  end

  def set_sf_type
    flush_ranks = []
    sorted_cards.each do |card|
      flush_ranks.push(card.rank) if card.suit == flush_suit
    end
    if royal_flush_steel_wheel?(flush_ranks)
      @sf_type = SF_TYPES[:RF_STEEL]
      set_rf_steel(flush_ranks)
      return
    end
    if flush_ranks.size >= ONE_CARD_NUT_SF_COUNT
      set_compound_sf(flush_ranks)
      return unless @sf_type.nil?
    end
    if three_consecutive_sf_cards?(flush_ranks)
      @sf_type = set_three_consecutive_sf_type(flush_ranks)
      return
    end
    if royal_flush?(flush_ranks)
      @sf_type = SF_TYPES[:ROYAL_FLUSH]
      set_royal_flush(flush_ranks)
      return
    end
    gaps = 0
    i = 0
    ranks_left = flush_ranks.size
    ranks_index = RANKS.index(flush_ranks[0])
    sf_blockers = []
    sf_ranks = []
    while i < flush_ranks.size
      sf_ranks.push(flush_ranks[i])
      break if sf_ranks.size >= MIN_RANKS_SF_STRAIGHT

      ranks_left -= 1
      next_rank = flush_ranks[i + 1]
      next_flush_ranks_index = RANKS.index(next_rank).nil? ? 0 : RANKS.index(next_rank)
      gap_size = next_flush_ranks_index - 1 - ranks_index
      gaps += gap_size
      if gap_size > MAX_GAPS_SF_STRAIGHT && ranks_left < MIN_RANKS_SF_STRAIGHT
        set_steel_wheel(flush_ranks)
        return
      end

      if gap_size > MAX_GAPS_SF_STRAIGHT
        sf_blockers.clear
        gaps = 0
        sf_ranks.clear
      elsif gaps > MAX_GAPS_SF_STRAIGHT
        shift_bad_ranks(sf_ranks, sf_blockers, next_rank)
        gaps = gap_size
        j = 0
        while j < sf_ranks.size - 1
          gaps += calc_gaps(sf_ranks[j], sf_ranks[j + 1])
          j += 1
        end
        add_gaps(sf_blockers, gap_size, ranks_index + 1)
      else
        add_gaps(sf_blockers, gap_size, ranks_index + 1)
      end

      i += 1
      ranks_index = next_flush_ranks_index
    end

    @sf_type = gaps
    set_gaps(sf_blockers)
    set_sf_straight_ranks(sf_ranks)
  end

  def filter_broadway_ranks
    sorted_cards.filter(&:broadway_card?).map(&:rank)
  end

  def find_sw_gaps(filtered_ranks)
    sw_ranks = %w[5 4 3 2 A]
    sw_ranks.filter { |rank| !filtered_ranks.include?(rank) }
  end

  def find_wheel_gaps(filtered_ranks)
    wheel_ranks = %w[5 4 3 2 A]
    wheel_ranks.filter { |rank| !filtered_ranks.include?(rank) }
  end

  def find_broadway_gaps(filtered_ranks)
    broadway_ranks = %w[A K Q J T]
    broadway_ranks.filter { |rank| !filtered_ranks.include?(rank) }
  end

  def set_one_card_steel_wheel(sf_ranks)
    # code here
    filtered_ranks = sf_ranks.filter do |rank|
      wheel_card?(rank)
    end
    if filtered_ranks.size >= ONE_CARD_NUT_SF_COUNT
      sw_gaps = find_sw_gaps(filtered_ranks)
      set_gaps(sw_gaps)
      @sf_type = SF_TYPES[:ONE_CARD_SW]
    end
  end

  def set_one_card_sf(sf_ranks)

    current_gaps = 0
    total_gaps = 0
    i = 0
    ranks_left = sf_ranks.size
    ranks_index = RANKS.index(sf_ranks[0])
    sf_blockers = []
    sf_cards = []
    while i < sf_ranks.size
      sf_cards.push(sf_ranks[i])
      break if sf_cards.size >= ONE_CARD_NUT_SF_COUNT
      #return if sf_cards.size >= MIN_RANKS_SF_STRAIGHT && total_gaps.zero?

      ranks_left -= 1
      next_rank = sf_ranks[i + 1]
      next_sf_ranks_index = RANKS.index(next_rank).nil? ? 0 : RANKS.index(next_rank)
      gap_size = next_sf_ranks_index - 1 - ranks_index
      current_gaps += gap_size
      total_gaps += gap_size
      if current_gaps > MAX_GAPS_ONE_CARD_SF && ranks_left < MIN_RANKS_SF_STRAIGHT
        set_one_card_steel_wheel(sf_ranks)
        return
      end

      if current_gaps > MAX_GAPS_ONE_CARD_SF
        sf_blockers.clear
        current_gaps = 0
        sf_cards.clear
      else
        add_gaps(sf_blockers, gap_size, ranks_index + 1)
      end

      i += 1
      ranks_index = next_sf_ranks_index
    end
    if sf_cards.size >= ONE_CARD_NUT_SF_COUNT
      @sf_type = SF_TYPES[:ONE_CARD]
      set_gaps(sf_blockers)
      set_sf_straight_ranks(sf_cards)
      @one_card_nuts = calc_one_card_sf_nuts(sf_blockers, sf_cards)
    end
  end

  def calc_one_card_sf_nuts(sf_blockers, sf_cards)
    if sf_blockers.size.positive?
      sf_blockers[0]
    elsif sf_cards[0] == 'A'
      'T'
    else
      RANKS[RANKS.index(sf_cards[0]) - 1]
    end
  end

  def add_gaps(sf_blockers, gap_size, ranks_index)
    while gap_size.positive?
      sf_blockers.push(RANKS[ranks_index])
      gap_size -= 1
      ranks_index += 1
    end
  end

  def set_gaps(sf_blockers)
    @gap_ranks = sf_blockers.join
  end

  def middle_card_rank
    sorted_cards[MIDDLE_CARD_INDEX].rank
  end

  ###############################################################################################
  def set_sf_alt_nuts
    set_sf_pair_type if board_paired?
  end

  def board_trips?
    rank_counts.any? { |rank| rank[1] >= TRIPS_COUNT }
  end

  def find_trips_rank
    found = rank_counts.filter { |rank| rank_counts[rank] == TRIPS_COUNT }
    found.keys[0]
  end

  def find_pair_rank
    found = rank_counts.filter { |rank| rank_counts[rank] == PAIR_COUNT }
    found.keys[0]
  end

  def top_paired_next_gap?
    top_card_paired? && sf_gap_after_pair? && sorted_cards[FOURTH_CARD_INDEX].suit == flush_suit && sorted_cards[LAST_CARD_INDEX].suit == flush_suit
  end

  def top_card_paired?
    rank_counts[sorted_cards[FIRST_CARD_INDEX].rank] == PAIR_COUNT
  end

  def filter_pairs
    sorted_cards.filter{ |card| rank_counts[card.rank] == PAIR_COUNT }
  end

  def last_card_paired?
    rank_counts[sorted_cards[LAST_CARD_INDEX].rank] == PAIR_COUNT
  end

  def sf_gap_after_pair?
    sorted_cards[MIDDLE_CARD_INDEX].suit != flush_suit
  end

  def pair_in_gap?
    (sorted_cards[FIRST_CARD_INDEX].suit == flush_suit && sorted_cards[LAST_CARD_INDEX].suit == flush_suit && sorted_cards[SECOND_CARD_INDEX].rank == sorted_cards[MIDDLE_CARD_INDEX].rank || sorted_cards[MIDDLE_CARD_INDEX].rank == sorted_cards[FOURTH_CARD_INDEX].rank) || (sorted_cards[FIRST_CARD_INDEX].suit == flush_suit && sorted_cards[SECOND_CARD_INDEX].suit == flush_suit && sorted_cards[MIDDLE_CARD_INDEX].suit == flush_suit && (sorted_cards[FOURTH_CARD_INDEX].rank == 'J' || sorted_cards[FOURTH_CARD_INDEX].rank == 'T') && sorted_cards[FOURTH_CARD_INDEX].rank == sorted_cards[LAST_CARD_INDEX].rank)
  end

  def fives_on_432?
    sorted_cards[FIRST_CARD_INDEX].rank == '5' && sorted_cards[SECOND_CARD_INDEX].rank == '5' && sf_type == SF_TYPES[:FOUR_THREE_TWO]
  end

  def tens_on_kqj?
    sf_type == SF_TYPES[:KQJ] && sorted_cards[FOURTH_CARD_INDEX].rank == 'T' && sorted_cards[LAST_CARD_INDEX].rank == 'T'
  end

  def set_sf_pair_type
    @sf_pair_type = calc_sf_pair_type
  end

  def calc_sf_pair_type
    if board_trips?
      SF_PAIR_TYPES[:TRIPS]
    elsif fives_on_432?
      SF_PAIR_TYPES[:FIVES_ON_432]
    elsif tens_on_kqj?
      SF_PAIR_TYPES[:TENS_ON_KQJ]
    elsif top_paired_next_gap?
      SF_PAIR_TYPES[:TOP_PAIRED_NEXT_GAP]
    elsif pair_in_gap?
      SF_PAIR_TYPES[:PAIR_IN_GAP]
    else
      SF_PAIR_TYPES[:OTHER_PAIRED]
    end
  end

  def one_card_flush_possible?
    # code here
    !flush_suit.nil? && sorted_cards.filter { |card| card.suit == flush_suit }.size >= ONE_CARD_FLUSH_COUNT
  end

  def flush_possible?
    !flush_suit.nil?
  end

  def one_card_broadway?
    sorted_cards.filter(&:broadway_card?).size >= ONE_CARD_STRAIGHT_COUNT
  end

  def straight_possible?
    find_straight
    !straight_type.nil?
  end

  def set_nut_type
    @nut_type = find_nut_type
  end

  def find_nut_type
    if nut_board
      NUT_TYPES[:NUT_BOARD]
    elsif sf_type == SF_TYPES[:ONE_CARD]
      NUT_TYPES[:ONE_CARD_SF]
    elsif !sf_type.nil?
      NUT_TYPES[:STRAIGHT_FLUSH]
    elsif board_quads?
      NUT_TYPES[:BOARD_QUADS]
    elsif board_trips?
      NUT_TYPES[:ONE_CARD_QUADS]
    elsif board_paired?
      NUT_TYPES[:QUADS_FULL_HOUSE]
    elsif one_card_flush_possible?
      NUT_TYPES[:ONE_CARD_FLUSH]
    elsif flush_possible?
      NUT_TYPES[:FLUSH]
    elsif one_card_broadway?
      NUT_TYPES[:ONE_CARD_STRAIGHT]
    elsif straight_possible?
      NUT_TYPES[:STRAIGHT]
    else
      NUT_TYPES[:SET]
    end
  end

  def two_card_broadway?
    sorted_cards.filter(&:broadway_card?).size >= MIN_RANKS_SF_STRAIGHT
  end

  def find_straight
    if two_card_broadway?
      broadway_ranks = find_broadway_ranks_from_cards
      broadway_gaps = find_broadway_gaps(broadway_ranks)
      set_gaps(broadway_gaps)
      @straight_type = STRAIGHT_TYPES[:BROADWAY]
      return
    end
    board_ranks = sorted_cards.map(&:rank)
    gaps = 0
    i = 0
    ranks_left = board_ranks.size
    ranks_index = RANKS.index(board_ranks[0])
    blockers = []
    straight_ranks = []
    while i < board_ranks.size
      straight_ranks.push(board_ranks[i])
      break if straight_ranks.size >= MIN_RANKS_SF_STRAIGHT

      ranks_left -= 1
      next_rank = board_ranks[i + 1]
      next_ranks_index = RANKS.index(next_rank).nil? ? 0 : RANKS.index(next_rank)
      gap_size = next_ranks_index - 1 - ranks_index
      gaps += gap_size
      if gaps > MAX_GAPS_SF_STRAIGHT && ranks_left < MIN_RANKS_SF_STRAIGHT
        set_wheel(board_ranks)
        return
      end

      if gaps > MAX_GAPS_SF_STRAIGHT
        blockers.clear
        gaps = 0
        straight_ranks.clear
      else

        add_gaps(blockers, gap_size, ranks_index + 1)
      end

      i += 1
      ranks_index = next_ranks_index


    end

    @straight_type = gaps
    set_gaps(blockers)
    set_sf_straight_ranks(straight_ranks)
  end

  def set_sf_straight_ranks(ranks)
    @sf_straight_ranks = ranks.join
  end

  ######################################################################################################################
  ######################################################################################################################

  def set_set_nut_combos
    nuts = "#{sorted_cards[0].rank}#{ANY_SUIT}#{CARD_SEP}#{sorted_cards[0].rank}#{ANY_SUIT}"
    @nut_combos.push(nuts)
  end

  def set_nut_board_combos
    nuts = "#{ANY_RANK}#{ANY_SUIT}#{CARD_SEP}#{ANY_RANK}#{ANY_SUIT}"
    @nut_combos.push(nuts)
  end

  def set_one_card_sf_nut_combos
    if gap_ranks.size.positive?
      set_one_card_gap_sf_nut_combos
    else
      set_one_card_no_gap_sf_nut_combos
    end
  end

  def set_one_card_no_gap_sf_nut_combos
    nuts = "#{RANKS[RANKS.index(sf_straight_ranks[0]) - 1]}#{flush_suit}#{CARD_SEP}#{ANY_RANK}#{ANY_SUIT}"
    @nut_combos.push(nuts)
  end

  def set_one_card_gap_sf_nut_combos
    nuts = "#{gap_ranks[0]}#{flush_suit}#{CARD_SEP}#{ANY_RANK}#{ANY_SUIT}"
    @nut_combos.push(nuts)
  end

  def set_zero_gap_sf_nuts
    nuts = "#{RANKS[RANKS.index(sf_straight_ranks[0]) - 2]}#{flush_suit}#{CARD_SEP}#{RANKS[RANKS.index(sf_straight_ranks[0]) - 1]}#{flush_suit}#{COMBO_SEP}#{RANKS[RANKS.index(sf_straight_ranks[0]) - 1]}#{flush_suit}#{CARD_SEP}#{RANKS[RANKS.index(sf_straight_ranks[2]) + 1]}#{flush_suit}"
    @nut_combos.push(nuts)
  end

  def set_sf_trips_nuts
    if gap_ranks.size == 1
      set_sf_trips_one_gap_nuts
    else
      set_sf_trips_two_gaps_nuts
    end
  end

  def set_sf_trips_one_gap_nuts
    trips_rank = find_trips_rank
    gap_rank = gap_ranks[0]
    nuts = "#{RANKS[RANKS.index(sf_straight_ranks[0]) - 1]}#{flush_suit}#{CARD_SEP}#{gap_rank}#{flush_suit}#{COMBO_SEP}#{gap_rank}#{flush_suit}#{CARD_SEP}#{RANKS[RANKS.index(sf_straight_ranks[2]) + 1]}#{flush_suit}#{COMBO_SEP}#{trips_rank}#{ANY_SUIT}#{CARD_SEP}#{gap_rank}#{flush_suit}"
    @nut_combos.push(nuts)
  end

  def set_sf_trips_two_gaps_nuts
    trips_rank = find_trips_rank
    nuts = "#{gap_ranks[0]}#{flush_suit}#{CARD_SEP}#{gap_ranks[1]}#{flush_suit}#{COMBO_SEP}#{trips_rank}#{ANY_SUIT}#{CARD_SEP}#{gap_ranks[0]}#{flush_suit}#{COMBO_SEP}#{trips_rank}#{ANY_SUIT}#{CARD_SEP}#{gap_ranks[1]}#{flush_suit}"
    @nut_combos.push(nuts)
  end


  def set_sf_top_paired_one_gap_nuts
    pair_rank = find_pair_rank
    gap_rank = gap_ranks[0]
    nuts = "#{RANKS[RANKS.index(sf_straight_ranks[0]) - 1]}#{flush_suit}#{CARD_SEP}#{gap_rank}#{flush_suit}#{COMBO_SEP}#{gap_rank}#{flush_suit}#{CARD_SEP}#{RANKS[RANKS.index(sf_straight_ranks[2]) + 1]}#{flush_suit}#{COMBO_SEP}#{pair_rank}#{ANY_SUIT}#{CARD_SEP}#{middle_card_rank}#{flush_suit}"
    @nut_combos.push(nuts)
  end



  def set_sf_top_paired_two_gaps_nuts
    pair_rank = find_pair_rank
    nuts = "#{gap_ranks[0]}#{flush_suit}#{CARD_SEP}#{gap_ranks[1]}#{flush_suit}#{COMBO_SEP}#{pair_rank}#{ANY_SUIT}#{CARD_SEP}#{middle_card_rank}#{flush_suit}"
    @nut_combos.push(nuts)
  end

  def set_sf_top_paired_nuts
    if gap_ranks.size == 1
      set_sf_top_paired_one_gap_nuts
    else
      set_sf_top_paired_two_gaps_nuts
    end
  end

  def set_sf_pair_in_one_gap_nuts
    pair_rank = find_pair_rank
    gap_rank = gap_ranks[0]
    nuts = "#{RANKS[RANKS.index(sf_straight_ranks[0]) - 1]}#{flush_suit}#{CARD_SEP}#{gap_rank}#{flush_suit}#{COMBO_SEP}#{gap_rank}#{flush_suit}#{CARD_SEP}#{RANKS[RANKS.index(sf_straight_ranks[2]) + 1]}#{flush_suit}#{COMBO_SEP}#{pair_rank}#{flush_suit}#{CARD_SEP}#{pair_rank}#{ANY_SUIT}"
    @nut_combos.push(nuts)
  end

  def set_sf_pair_in_two_gaps_nuts
    pair_rank = find_pair_rank
    nuts = "#{gap_ranks[0]}#{flush_suit}#{CARD_SEP}#{gap_ranks[1]}#{flush_suit}#{COMBO_SEP}#{pair_rank}#{flush_suit}#{CARD_SEP}#{pair_rank}#{ANY_SUIT}"
    @nut_combos.push(nuts)
  end

  def set_sf_pair_in_gap_nuts
    if gap_ranks.size == 1
      set_sf_pair_in_one_gap_nuts
    else
      set_sf_pair_in_two_gaps_nuts
    end
  end

  def set_sf_fives_on_432_nuts
    nuts = "#{RANKS[RANKS.index(sf_straight_ranks[0]) - 2]}#{flush_suit}#{CARD_SEP}#{RANKS[RANKS.index(sf_straight_ranks[0]) - 1]}#{flush_suit}#{COMBO_SEP}#{RANKS[RANKS.index(sf_straight_ranks[0]) - 1]}#{flush_suit}#{CARD_SEP}A#{flush_suit}#{COMBO_SEP}5#{flush_suit}#{CARD_SEP}5#{ANY_SUIT}#{COMBO_SEP}5#{flush_suit}4#{ANY_SUIT}"
    @nut_combos.push(nuts)
  end

  def set_sf_tens_on_kqj_nuts
    nuts = "#{RANKS[RANKS.index(sf_straight_ranks[0]) - 1]}#{flush_suit}#{CARD_SEP}#{RANKS[RANKS.index(sf_straight_ranks[0]) + 1]}#{flush_suit}#{COMBO_SEP}#{RANKS[RANKS.index(sf_straight_ranks[0]) + 1]}#{flush_suit}#{CARD_SEP}#{RANKS[RANKS.index(sf_straight_ranks[0]) + 2]}#{flush_suit}#{COMBO_SEP}T#{flush_suit}T#{ANY_SUIT}"
    @nut_combos.push(nuts)
  end

  def set_sf_other_paired_one_gap_nuts
    nuts = "#{RANKS[RANKS.index(sf_straight_ranks[0]) - 1]}#{flush_suit}#{CARD_SEP}#{gap_ranks[0]}#{flush_suit}#{COMBO_SEP}#{gap_ranks[0]}#{flush_suit}#{CARD_SEP}#{RANKS[RANKS.index(sf_straight_ranks[2]) + 1]}#{flush_suit}"
    @nut_combos.push(nuts)
  end

  def set_sf_other_paired_two_gaps_nuts
    nuts = "#{gap_ranks[0]}#{flush_suit}#{CARD_SEP}#{gap_ranks[1]}#{flush_suit}"
    @nut_combos.push(nuts)
  end

  def set_sf_other_paired_nuts
    if gap_ranks.size == 1
      set_sf_other_paired_one_gap_nuts
    else
      set_sf_other_paired_two_gaps_nuts
    end
  end

  def set_sf_pair_nut_combos
    case sf_pair_type
    when SF_PAIR_TYPES[:TRIPS]
      set_sf_trips_nuts
    when SF_PAIR_TYPES[:TOP_PAIRED_NEXT_GAP]
      set_sf_top_paired_nuts
    when SF_PAIR_TYPES[:PAIR_IN_GAP]
      set_sf_pair_in_gap_nuts
    when SF_PAIR_TYPES[:FIVES_ON_432]
      set_sf_fives_on_432_nuts
    when SF_PAIR_TYPES[:TENS_ON_KQJ]
      set_sf_tens_on_kqj_nuts
    when SF_PAIR_TYPES[:OTHER_PAIRED]
      set_sf_other_paired_nuts
    else
      puts "I can't set the sf pair type"
    end
  end

  def set_sf_nut_combos
    if sf_pair_type.nil?
      set_sf_reg_nut_combos
    else
      set_sf_pair_nut_combos
    end
  end

  def set_one_gap_sf_nuts
    nut_flush_rank = find_highest_missing_flush_rank
    nuts = "#{RANKS[RANKS.index(sf_straight_ranks[0]) - 1]}#{flush_suit}#{CARD_SEP}#{gap_ranks[0]}#{flush_suit}#{COMBO_SEP}#{gap_ranks[0]}#{flush_suit}#{CARD_SEP}#{RANKS[RANKS.index(sf_straight_ranks[2]) + 1]}#{flush_suit}#{COMBO_SEP}#{nut_flush_rank}#{flush_suit}#{CARD_SEP}#{gap_ranks[0]}#{flush_suit}"
    @nut_combos.push(nuts)
  end

  def set_one_gap_compound_sf_nuts(sf_combo_index)

    "#{RANKS[RANKS.index(@compound_sf_ranks[sf_combo_index][0]) - 1]}#{flush_suit}#{CARD_SEP}#{compound_sf_gaps[sf_combo_index][0]}#{flush_suit}#{COMBO_SEP}#{compound_sf_gaps[sf_combo_index][0]}#{flush_suit}#{CARD_SEP}#{RANKS[RANKS.index(@compound_sf_ranks[sf_combo_index][2]) + 1]}#{flush_suit}"

  end

  def set_two_gap_sf_nuts
    nut_flush_rank = find_highest_missing_flush_rank
    nuts = "#{gap_ranks[0]}#{flush_suit}#{CARD_SEP}#{gap_ranks[1]}#{flush_suit}#{COMBO_SEP}#{nut_flush_rank}#{flush_suit}#{CARD_SEP}#{gap_ranks[0]}#{flush_suit}#{COMBO_SEP}#{nut_flush_rank}#{flush_suit}#{CARD_SEP}#{gap_ranks[1]}#{flush_suit}"
    @nut_combos.push(nuts)
  end

  def set_two_gap_compound_sf_nuts(sf_combo_index)
    "#{compound_sf_gaps[sf_combo_index][0]}#{flush_suit}#{CARD_SEP}#{compound_sf_gaps[sf_combo_index][1]}#{flush_suit}"
  end

  def set_steel_wheel_sf_nuts
    set_two_gap_sf_nuts
  end

  def set_royal_flush_nuts
    nuts = "#{gap_ranks[0]}#{flush_suit}#{CARD_SEP}#{gap_ranks[1]}#{flush_suit}#{COMBO_SEP}#{gap_ranks[0]}#{flush_suit}#{CARD_SEP}#{ANY_RANK}#{flush_suit}"
    @nut_combos.push(nuts)
  end

  def set_sf_kqj_nuts
    nuts = "#{RANKS[RANKS.index(sf_straight_ranks[0]) - 1]}#{flush_suit}#{CARD_SEP}#{RANKS[RANKS.index(sf_straight_ranks[0]) + 1]}#{flush_suit}#{COMBO_SEP}#{RANKS[RANKS.index(sf_straight_ranks[0]) + 1]}#{flush_suit}#{CARD_SEP}#{RANKS[RANKS.index(sf_straight_ranks[0]) + 2]}#{flush_suit}"
    @nut_combos.push(nuts)
  end

  def set_sf_432_nuts
    nuts = "#{RANKS[RANKS.index(sf_straight_ranks[0]) - 2]}#{flush_suit}#{CARD_SEP}#{RANKS[RANKS.index(sf_straight_ranks[0]) - 1]}#{flush_suit}#{COMBO_SEP}#{RANKS[RANKS.index(sf_straight_ranks[0]) - 1]}#{flush_suit}A#{flush_suit}"
    @nut_combos.push(nuts)
  end

  def set_rf_steel_nuts
    nuts = "#{gap_ranks[0]}#{flush_suit}#{CARD_SEP}#{gap_ranks[1]}#{flush_suit}"
    @nut_combos.push(nuts)
  end

  def set_zero_gap_compound_sf_nuts(i)
    # code here
  end

  def set_sf_compound_nuts
    i = 0
    result = []
    while i < @compound_sf_ranks.size
      case @consecutive_gap_sizes[i]
      when SF_TYPES[:ZERO_GAPS]
        result.push(set_zero_gap_compound_sf_nuts(i))
      when SF_TYPES[:ONE_GAP]
        result.push(set_one_gap_compound_sf_nuts(i))
      when SF_TYPES[:TWO_GAPS]
        result.push(set_two_gap_compound_sf_nuts(i))
      end
      i += 1
    end
    # this part might be broken, but I think it's ok
    result = result.join(COMBO_SEP)
    result = result.split(COMBO_SEP)
    @nut_combos.push(result.slice(0,2).join(COMBO_SEP))
    #@nut_combos.push(result.slice(0,1).join(COMBO_SEP))
  end

  def set_sf_reg_nut_combos
    case sf_type
    when SF_TYPES[:ZERO_GAPS]
      set_zero_gap_sf_nuts
    when SF_TYPES[:ONE_GAP]
      set_one_gap_sf_nuts
    when SF_TYPES[:TWO_GAPS]
      set_two_gap_sf_nuts
    when SF_TYPES[:STEEL_WHEEL]
      set_steel_wheel_sf_nuts
    when SF_TYPES[:ROYAL_FLUSH]
      set_royal_flush_nuts
    when SF_TYPES[:RF_STEEL]
      set_rf_steel_nuts
    when SF_TYPES[:KQJ]
      set_sf_kqj_nuts
    when SF_TYPES[:FOUR_THREE_TWO]
      set_sf_432_nuts
    when SF_TYPES[:COMPOUND]
      set_sf_compound_nuts
    else
      puts "I can't set the sf reg type"
    end
  end

  def set_zero_gap_straight_nuts
    nuts = "#{RANKS[RANKS.index(sf_straight_ranks[0]) - 2]}#{ANY_SUIT}#{CARD_SEP}#{RANKS[RANKS.index(sf_straight_ranks[0]) - 1]}#{ANY_SUIT}"
    @nut_combos.push(nuts)
  end

  def set_one_gap_straight_nuts
    nuts = "#{RANKS[RANKS.index(sf_straight_ranks[0]) - 1]}#{ANY_SUIT}#{CARD_SEP}#{gap_ranks[0]}#{ANY_SUIT}"
    @nut_combos.push(nuts)
  end

  def set_two_gap_straight_nuts
    nuts = "#{gap_ranks[0]}#{ANY_SUIT}#{CARD_SEP}#{gap_ranks[1]}#{ANY_SUIT}"
    @nut_combos.push(nuts)
  end

  def set_wheel_straight_nuts
    nuts = "#{gap_ranks[0]}#{ANY_SUIT}#{CARD_SEP}#{gap_ranks[1]}#{ANY_SUIT}"
    @nut_combos.push(nuts)
  end

  def set_broadway_straight_nuts
    nuts = "#{gap_ranks[0]}#{ANY_SUIT}#{CARD_SEP}#{gap_ranks[1]}#{ANY_SUIT}"
    @nut_combos.push(nuts)
  end

  def set_straight_nut_combos
    case straight_type
    when STRAIGHT_TYPES[:ZERO_GAPS]
      set_zero_gap_straight_nuts
    when STRAIGHT_TYPES[:ONE_GAP]
      set_one_gap_straight_nuts
    when STRAIGHT_TYPES[:TWO_GAPS]
      set_two_gap_straight_nuts
    when STRAIGHT_TYPES[:WHEEL]
      set_wheel_straight_nuts
    when STRAIGHT_TYPES[:BROADWAY]
      set_broadway_straight_nuts
    else

      puts "I can't set the straight nut combo"
    end
  end

  def set_one_card_straight_combos
    ranks = find_broadway_gaps(filter_broadway_ranks)
    nuts = "#{ranks[0]}#{ANY_SUIT}#{CARD_SEP}#{ANY_RANK}#{ANY_SUIT}"
    @nut_combos.push(nuts)
  end

  def find_highest_missing_flush_rank
    flush_ranks = sorted_cards.filter { |card| card.suit == flush_suit }.map(&:rank)
    RANKS.find { |rank| !flush_ranks.include?(rank) }
  end

  def set_flush_nut_combos
    rank = find_highest_missing_flush_rank
    nuts = "#{rank}#{flush_suit}#{CARD_SEP}#{ANY_RANK}#{flush_suit}"
    @nut_combos.push(nuts)
  end

  def set_one_card_flush_combos
    rank = find_highest_missing_flush_rank
    nuts = "#{rank}#{flush_suit}#{CARD_SEP}#{ANY_RANK}#{ANY_SUIT}"
    @nut_combos.push(nuts)
  end

  def set_quads_fh_nut_combos
    if top_card_paired? && !last_card_paired?
      nuts = "#{sorted_cards[0].rank}#{ANY_SUIT}#{CARD_SEP}#{sorted_cards[0].rank}#{ANY_SUIT}#{COMBO_SEP}#{sorted_cards[0].rank}#{ANY_SUIT}#{CARD_SEP}#{sorted_cards[MIDDLE_CARD_INDEX].rank}#{ANY_SUIT}"
    else
      pair_cards = filter_pairs
      nuts = "#{pair_cards[0].rank}#{ANY_SUIT}#{CARD_SEP}#{pair_cards[0].rank}#{ANY_SUIT}"
    end
    @nut_combos.push(nuts)
  end

  def set_board_quads_nut_combos
    rank = board_quad_aces? ? 'K' : 'A'
    nuts = "#{rank}#{ANY_SUIT}#{CARD_SEP}#{ANY_RANK}#{ANY_SUIT}"
    @nut_combos.push(nuts)
  end

  def set_one_card_quads_nut_combos
    trips_rank = find_trips_rank
    nuts = "#{trips_rank}#{ANY_SUIT}#{CARD_SEP}#{ANY_RANK}#{ANY_SUIT}"
    @nut_combos.push(nuts)
  end

  def set_top_fh_nut_combos
    # Used only during no quads mode
    set_set_nut_combos
  end

  def set_nut_combos
    # code here
    case nut_type
    when NUT_TYPES[:NUT_BOARD]
      set_nut_board_combos
    when NUT_TYPES[:ONE_CARD_SF]
      set_one_card_sf_nut_combos
    when NUT_TYPES[:STRAIGHT_FLUSH]
      set_sf_nut_combos
    when NUT_TYPES[:ONE_CARD_QUADS]
      set_one_card_quads_nut_combos
    when NUT_TYPES[:BOARD_QUADS]
      set_board_quads_nut_combos
    when NUT_TYPES[:QUADS_FULL_HOUSE]
      set_quads_fh_nut_combos
    when NUT_TYPES[:TOP_FULL_HOUSE]
      set_top_fh_nut_combos
    when NUT_TYPES[:ONE_CARD_FLUSH]
      set_one_card_flush_combos
    when NUT_TYPES[:FLUSH]
      set_flush_nut_combos
    when NUT_TYPES[:ONE_CARD_STRAIGHT]
      set_one_card_straight_combos
    when NUT_TYPES[:STRAIGHT]
      set_straight_nut_combos
    when NUT_TYPES[:SET]
      set_set_nut_combos
    else
      puts "I can't set that nut combo"
    end
  end
end