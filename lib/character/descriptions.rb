# frozen_string_literal: true

class Character
  module Descriptions
    include Belongings
    include Dwarf
    include Human
    include PhysicalFeatures

    BUILD_HEIGHT_MODIFIER = Hash.new(1.0).merge(
      "Small" => 0.9,
      "Large" => 1.1,
      "Huge" => 1.2,
    ).freeze

    BUILD_WEIGHT_MODIFIER = Hash.new(1.0).merge(
      "Small" => 0.7,
      "Slim" => 0.8,
      "Broad" => 1.2,
      "Large" => 1.3,
      "Huge" => 1.75,
    ).freeze

    RANDOM_ALIGNMENT = { 2 => "Lawful", 5 => "Neutral", 6 => "Chaotic" }.freeze

    BASIC_HUMAN_CATEGORY = {
      7 => "belongings",
      20 => "appearance",
    }.freeze

    def human_descriptions(ethnicity, stats, sex, alignment)
      alignment ||= roll_table(RANDOM_ALIGNMENT)

      build_roll = roll_dice("2d6 + #{2 * stats.str_bonus}")
      build = roll_table(HUMAN_BUILD, build_roll)

      height_mod, weight_mod = HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.fetch(ethnicity) do |missing_key|
        keys = HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.keys
        spell_check = DidYouMean::SpellChecker.new(dictionary: keys).correct(missing_key)
        if spell_check.any?
          puts "Assuming you meant `#{spell_check.first}`."
          ethnicity = spell_check.first
          HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.fetch(ethnicity)
        else
          puts "Didn't find ethnicity '#{missing_key}'.  Valid choices: '#{keys.join "', '"}'."
          exit
        end
      end

      base_height = male?(sex) ? 60 : 55
      height_roll = roll_dice("2d6")
      height = ((base_height + height_roll + height_mod) * BUILD_HEIGHT_MODIFIER[build]).round
      height_string = "#{height / 12} feet #{height % 12} inches"

      base_weight = male?(sex) ? 110 : 90
      weight_roll = roll_dice("8d6")
      weight = ((base_weight + weight_roll) * BUILD_WEIGHT_MODIFIER[build] * weight_mod).round
      weight_string = "#{weight} pounds"

      eye_color = roll_table(HUMAN_EYE_COLOR_BY_ETHNICITY[ethnicity])
      skin_color = roll_table(HUMAN_SKIN_COLOR_BY_ETHNICITY[ethnicity])
      hair_color = roll_table(HUMAN_HAIR_COLOR_BY_ETHNICITY[ethnicity])
      hair_texture = roll_table(HUMAN_HAIR_TEXTURE_BY_ETHNICITY[ethnicity])

      features = roll_features(stats, sex)
      category = roll_table(BASIC_HUMAN_CATEGORY)
      features << roll_belongings(alignment) if category == "belongings"

      sex = male?(sex) ? "Male" : "Female"

      [
        "  Alignment: #{alignment.capitalize}, Sex: #{sex}, Features: #{features.join(', ')}",
        "  Build: #{build}, Height: #{height_string}, Weight: #{weight_string}",
        "  Ethnicity: #{ethnicity.capitalize}, Eyes: #{eye_color}, Skin Color: #{skin_color}, Hair: #{hair_texture} #{hair_color}",
      ]
    end

    def roll_features(stats, sex)
      features = []
      features << roll_table(NEUTRAL_PHYSICAL_FEATURES)
      if stats.cha_bonus.negative?
        stats.cha_bonus.abs.times { features << roll_table(NEGATIVE_PHYSICAL_FEATURES) }
      elsif stats.cha_bonus.positive?
        stats.cha_bonus.times { features << roll_table(POSITIVE_PHYSICAL_FEATURES) }
      end
      while features.include?("Roll Twice")
        features.delete_at(features.index("Roll Twice"))
        features << roll_table(POSITIVE_PHYSICAL_FEATURES)
        features << roll_table(POSITIVE_PHYSICAL_FEATURES)
      end
      features.map do |feature|
        if feature.include?("/")
          type, results = feature.split(" - ")
          result = results.split("/")[male?(sex) ? 0 : 1].strip
          "#{type} - #{result}"
        else
          feature
        end
      end
    end

    def roll_belongings(alignment)
      belonging_type = roll_table(BELONGING_TYPE)
      belongings_table = if self.class.const_defined?("#{alignment.upcase}_#{belonging_type.upcase}") && rand < 0.666
                           self.class.const_get("#{alignment.upcase}_#{belonging_type.upcase}")
                         else
                           self.class.const_get("ANY_#{belonging_type.upcase}")
                         end
      "#{belonging_type.capitalize}: #{roll_table(belongings_table)}"
    end

    def male?(sex_string)
      sex_string.downcase.start_with? "m"
    end
  end
end
