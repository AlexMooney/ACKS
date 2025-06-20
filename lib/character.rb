# frozen_string_literal: true

class Character
  include Tables
  include Descriptions
  include ClassTables
  include Names

  attr_accessor :level, :title, :character_class, :alignment, :sex, :name, :stats, :description, :magic_items_by_rarity

  def initialize(level, title = nil, class_type: nil, character_class: nil, ethnicity: nil, magic_items: true)
    @level = level
    @title = title # TODO: default class level titles
    if level.positive?
      class_type ||= roll_table(CLASS_TYPE)
      @character_class = character_class || roll_table(CLASS_BY_TYPE[class_type])
    else
      class_type = "normal_man"
      @character_class = "Normal Man"
    end
    @alignment = roll_table(RANDOM_ALIGNMENT)
    @sex = roll_table(SEX_BY_CLASS[character_class])
    ethnicity ||= HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.keys.sample
    if ["northern argollëan", "dwarven"].include?(ethnicity.downcase)
      ethnicity = HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.keys.sample
    end
    if @character_class.start_with? "Dwarven"
      ethnicity = "dwarven"
    elsif @character_class.start_with? "Elven"
      ethnicity = "elven"
    end
    @name = random_name(ethnicity, sex)
    @stats = Stats.new(STAT_PREFERENCE_BY_CLASS_TYPE[class_type])
    @description = if HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.key?(ethnicity)
                     if level > 1
                       human(ethnicity, stats, sex, alignment)
                     else
                       basic_human(ethnicity, stats, alignment)
                     end
                   else
                     "Not implemented yet: '#{ethnicity}'"
                   end

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
      "#{[title, name].compact.join(' ')}, #{character_class} level #{level}#{stat_summary}",
      "  #{description}",
      magic_item_list,
    ].compact.join("\n")
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

  def stat_summary
    statline = stats.to_s
    ", #{statline}" unless statline.empty?
  end
end
