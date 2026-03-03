# frozen_string_literal: true

class CharacterGenerator
  include Tables
  include CharacterLegacy::Names

  STATS = %w[STR INT WIL DEX CON CHA].freeze
  HUMAN_ETHNICITIES = CharacterLegacy::Descriptions::Human::HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.keys.freeze
  RANDOM_ALIGNMENT = CharacterLegacy::Descriptions::RANDOM_ALIGNMENT
  SEX_BY_CLASS = CharacterLegacy::ClassTables::SEX_BY_CLASS
  BONUS_BY_STAT = CharacterLegacy::Stats::BONUS_BY_STAT
  HUMAN_BUILD = CharacterLegacy::Descriptions::Human::HUMAN_BUILD
  HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY = CharacterLegacy::Descriptions::Human::HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY
  BUILD_HEIGHT_MODIFIER = CharacterLegacy::Descriptions::BUILD_HEIGHT_MODIFIER
  BUILD_WEIGHT_MODIFIER = CharacterLegacy::Descriptions::BUILD_WEIGHT_MODIFIER

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
    template = roll_die(3).sum
    alignment = roll_table(RANDOM_ALIGNMENT)
    sex = roll_sex
    ethnicity = roll_ethnicity
    name = random_name(ethnicity, sex)

    physical = if HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.key?(ethnicity)
                 roll_physical(stats, sex, ethnicity)
               else
                 {}
               end

    Character.new(
      level: @level,
      character_class: @character_class,
      class_type: @class_type,
      template: template,
      alignment: alignment,
      sex: sex,
      ethnicity: ethnicity,
      name: name,
      **stats,
      **physical,
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

  def roll_sex
    SEX_BY_CLASS[@character_class].sample
  end

  def roll_ethnicity
    if @character_class.start_with?("Dwarven")
      "dwarven"
    elsif @character_class.start_with?("Elven")
      "elven"
    else
      HUMAN_ETHNICITIES.sample
    end
  end

  def stat_bonus(value)
    roll_table(BONUS_BY_STAT, value)
  end

  def male?(sex_string)
    sex_string.downcase.start_with?("m")
  end

  def roll_physical(stats, sex, ethnicity)
    str_bonus = stat_bonus(stats[:str])
    build_roll = roll_die(2).sum + (2 * str_bonus)
    build = roll_table(HUMAN_BUILD, build_roll)

    height_mod, weight_mod = HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY[ethnicity]
    base_height = male?(sex) ? 60 : 55
    height = ((base_height + roll_die(2).sum + height_mod) * BUILD_HEIGHT_MODIFIER[build]).round

    base_weight = male?(sex) ? 110 : 90
    weight = ((base_weight + roll_die(8).sum) * BUILD_WEIGHT_MODIFIER[build] * weight_mod).round

    { build: build, height_inches: height, weight_lbs: weight }
  end

  def roll_die(count)
    count.times.map { rand(1..6) }
  end
end
