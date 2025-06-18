# frozen_string_literal: true

class Character
  class Stats
    include Tables

    STATS = %w[STR INT WIL DEX CON CHA].freeze
    attr_reader :str, :int, :wil, :dex, :con, :cha, :best, :boost1, :boost2

    def initialize(stat_preference)
      @best = stat_preference.best
      @boost1 = stat_preference.always_good&.first || STATS.reject do |s|
        s == best || stat_preference.never_good.include?(s)
      end.sample
      @boost2 = stat_preference.always_good&.[](1) || STATS.reject do |s|
        s == best || boost1 == s || stat_preference.never_good&.include?(s)
      end.sample
      STATS.each(&method(:roll_stat))
    end

    def to_s
      bonuses = STATS.filter_map do |stat|
        stat = stat.downcase
        bonus = send("#{stat}_bonus")
        "#{stat.upcase} #{bonus >= 0 ? '+' : ''}#{bonus}" if bonus != 0
      end
      bonuses.join(", ")
    end

    BONUS_BY_STAT = {
      3 => -3,
      5 => -2,
      8 => -1,
      12 => 0,
      15 => 1,
      17 => 2,
      18 => 3,
    }.freeze
    STATS.each do |stat|
      stat = stat.downcase
      define_method("#{stat}_bonus") do
        value = instance_variable_get("@#{stat}")
        roll_table(BONUS_BY_STAT, value)
      end
    end

    private

    def roll_stat(stat)
      result = if stat == best
                 [[roll_die, roll_die, roll_die, roll_die, roll_die].sort.last(3).sum, 13].max
               elsif stat == boost1 || stat == boost2
                 [[roll_die, roll_die, roll_die, roll_die].sort.last(3).sum, 9].max
               else
                 [roll_die, roll_die, roll_die].sum
               end
      instance_variable_set("@#{stat.downcase}", result)
    end

    def roll_die
      rand(1..6)
    end
  end
end
