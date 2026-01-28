# frozen_string_literal: true

class Character
  include Tables
  include Descriptions
  include ClassTables
  include Names
  include SpellCheck

  SPELLING_ETHNICITIES = (HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.keys + ["dwarven", "elven"]).freeze

  attr_accessor :level, :title, :character_class, :stats, :template, :ethnicity
  attr_accessor :alignment, :sex, :name, :descriptions, :magic_items_by_rarity

  def initialize(level, title = nil, class_type: nil, character_class: nil, ethnicity: nil, sex: nil, magic_items: true)
    @level = level
    @title = title # TODO: default class level titles
    if level.positive?
      if class_type.nil? && character_class.nil?
        class_type = roll_table(CLASS_TYPE)
      elsif class_type.nil?
        class_type = CLASS_BY_TYPE.detect do |type, class_table|
          type if class_table.value?(character_class)
        end&.first
        raise "Didn't find a class type for class #{character_class}." unless class_type
      end
      @character_class = character_class || roll_table(CLASS_BY_TYPE[class_type])
      @template = roll_dice("3d6")
    else
      class_type = "normal_man"
      @character_class = "Normal Man"
    end
    @alignment = roll_table(RANDOM_ALIGNMENT)
    sex ||= roll_table(SEX_BY_CLASS[@character_class])
    @sex = sex
    ethnicity ||= HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.keys.sample
    if ["northern argollëan", "dwarven"].include?(ethnicity.downcase)
      ethnicity = HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.keys.sample
    end
    if @character_class.start_with? "Dwarven"
      ethnicity = "dwarven"
    elsif @character_class.start_with? "Elven"
      ethnicity = "elven"
    end
    @ethnicity = spell_check(ethnicity, SPELLING_ETHNICITIES)
    @name = random_name(ethnicity, sex)
    stat_preference = STAT_PREFERENCE_BY_CLASS[@character_class] || STAT_PREFERENCE_BY_CLASS_TYPE[class_type]
    @stats = Stats.new(stat_preference)
    @descriptions = generate_descriptions

    @magic_items_by_rarity = {}
    generate_magic_items! if magic_items
  end

  def to_s
    magic_item_list = magic_items_by_rarity.filter_map do |rarity, items|
      next if items.empty?

      "  #{rarity.capitalize} magic items: " + items.map(&:to_s).sort.join(", ")
    end
    magic_item_list = nil if magic_item_list.empty?
    [
      "#{[title, name].compact.join(' ')}, #{character_class} level #{level}#{stat_summary} template: #{template}",
      attack_throw_lines,
      descriptions,
      magic_item_list,
    ].flatten.compact.join("\n")
  end

  def base_attack_throw
    Character::AttackThrows.attack_throw(character_class, level)
  end

  MASTERWORK_BONUS = 1

  def base_damage_bonus
    Character::AttackThrows.damage_bonus(character_class, level)
  end

  def melee_damage_bonus
    base = base_damage_bonus
    return nil unless base

    stats.str_bonus + base + MASTERWORK_BONUS
  end

  def ranged_damage_bonus
    MASTERWORK_BONUS
  end

  def melee_attack
    base = base_attack_throw
    return nil unless base

    base - stats.str_bonus - MASTERWORK_BONUS
  end

  def ranged_attack
    base = base_attack_throw
    return nil unless base

    base - stats.dex_bonus - MASTERWORK_BONUS
  end

  SHIELD_CLASSES = %w[Fighter Crusader Explorer Barbarian Bard].freeze

  def base_armor_ac
    Character::Armor.base_ac(character_class) || 0
  end

  def uses_shield?
    SHIELD_CLASSES.include?(character_class)
  end

  def shield_ac
    uses_shield? ? (1 + MASTERWORK_BONUS) : 0
  end

  def armor_class
    base_armor_ac + MASTERWORK_BONUS + shield_ac + stats.dex_bonus
  end

  def attack_throw_lines
    return nil unless base_attack_throw

    [
      "  AC: #{armor_class}",
      "  Melee Attack: #{melee_attack}+, #{format_damage_dice(melee_damage_bonus)}",
      "  Ranged Attack: #{ranged_attack}+, #{format_damage_dice(ranged_damage_bonus)}"
    ]
  end

  def format_damage_dice(bonus)
    return "1d6" if bonus.zero?

    bonus.positive? ? "1d6+#{bonus}" : "1d6#{bonus}"
  end

  def <=>(other)
    lvl_cmp = other.level <=> level
    if lvl_cmp.zero?
      title_cmp = character_class <=> other.character_class
      if title_cmp.zero?
        other.magic_items_by_rarity.values.flatten.count <=> magic_items_by_rarity.values.flatten.count
      else
        title_cmp
      end
    else
      lvl_cmp
    end
  end

  COMMON_ITEMS_BY_LEVEL = {
    1 => "30%",
    2 => "90%",
    3 => 1,
    4 => "1d4-1",
    5 => 2,
    6 => 4,
    7 => 4,
  }.freeze
  UNCOMMON_ITEMS_BY_LEVEL = {
    3 => "15%",
    4 => "40%",
    5 => 1,
    6 => 2,
    7 => 2,
  }.freeze
  RARE_ITEMS_BY_LEVEL = {
    7 => "66%",
  }.freeze
  def generate_magic_items!
    count_by_rarity = %i[rare uncommon common].filter_map do |rarity|
      prefix = rarity.upcase
      quantity = roll_dice(self.class.const_get("#{prefix}_ITEMS_BY_LEVEL")[level])
      next if quantity.nil? || quantity.zero?

      [rarity, quantity]
    end.to_h
    return if count_by_rarity.empty?

    @magic_items_by_rarity = TTMagicItems.new(**count_by_rarity).magic_items_by_rarity
  end

  def generate_descriptions
    if HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.key?(ethnicity)
      human_descriptions(ethnicity, stats, sex, alignment)
    else
      ["Not implemented yet: '#{ethnicity}'"]
    end
  end

  def stat_summary
    statline = stats.to_s
    ", #{statline}" unless statline.empty?
  end
end
