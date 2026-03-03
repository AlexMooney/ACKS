# frozen_string_literal: true

class CharacterGenerator
  include Tables

  STATS = %w[STR INT WIL DEX CON CHA].freeze

  def initialize(character_class: nil, class_type: nil, level: 1)
    @level = level

    if character_class.nil? && class_type.nil?
      @class_type = roll_table(CharacterLegacy::ClassTables::CLASS_TYPE)
    elsif class_type.nil?
      @class_type = CharacterLegacy::ClassTables::CLASS_BY_TYPE.detect do |_type, table|
        table.value?(character_class)
      end&.first
      raise ArgumentError, "Unknown character class: #{character_class}" unless @class_type
    else
      @class_type = class_type
    end

    @character_class = character_class || roll_table(CharacterLegacy::ClassTables::CLASS_BY_TYPE[@class_type])
  end

  def generate
    stats = roll_stats
    Character.new(
      level: @level,
      character_class: @character_class,
      class_type: @class_type,
      **stats,
    )
  end

  private

  def roll_stats
    stat_preference = CharacterLegacy::ClassTables::STAT_PREFERENCE_BY_CLASS[@character_class] ||
                      CharacterLegacy::ClassTables::STAT_PREFERENCE_BY_CLASS_TYPE[@class_type]

    best = stat_preference.best
    boost1 = stat_preference.always_good&.first || STATS.reject do |s|
      s == best || stat_preference.never_good&.include?(s)
    end.sample
    boost2 = stat_preference.always_good&.[](1) || STATS.reject do |s|
      s == best || s == boost1 || stat_preference.never_good&.include?(s)
    end.sample

    STATS.to_h do |stat|
      value = if stat == best
                [roll_die(5).sort.last(3).sum, 13].max
              elsif stat == boost1 || stat == boost2
                [roll_die(4).sort.last(3).sum, 9].max
              else
                roll_die(3).sum
              end
      [stat.downcase.to_sym, value]
    end
  end

  def roll_die(count)
    count.times.map { rand(1..6) }
  end
end
