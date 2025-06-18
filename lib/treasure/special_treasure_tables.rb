# frozen_string_literal: true

class Treasure
  module SpecialTreasureTables
    TreasureObjectType = Data.define(:description, :amount_dice, :value_dice, :coin_weight) do
      # Most treasures have a fixed value, but e.g. pelts are rolled. 1000 coins weighs 1 st.

      include Tables

      def roll
        rolled_description = sub_tables(description)
        Lot.new(rolled_description, roll_dice(amount_dice), roll_dice(value_dice), coin_weight)
      end

      def sub_tables(string)
        string.sub(/{([^}]+)}/) do
          match_content = ::Regexp.last_match(1)
          SpecialTreasureTables.const_get(match_content).sample
        end
      end
    end

    CP_LOT = TreasureObjectType.new("copper pieces", 1000, 0.01, 1).freeze
    SP_FROM_CP = TreasureObjectType.new("silver pieces", 100, 0.1, 1).freeze
    CP_GOODS_TABLE = [
      TreasureObjectType.new("bags of grain or vegetables", "2d20", 0.5, 4_000),
      TreasureObjectType.new("bricks of salt", "4d6*10", 0.07, 500),
      TreasureObjectType.new("amphorae of beer", "2d10", 1, 7000),
      TreasureObjectType.new("crates of terra-cotta pottery", "6d6", 0.5, 3500),
      TreasureObjectType.new("bundles of hardwood logs", "2d10", 1, 6000),
      TreasureObjectType.new("amphorae of wine and spirits", "2d10", 1, 5000),
      TreasureObjectType.new("wheels of cheese", "4d20", 0.25, 500),
      TreasureObjectType.new("amphorae of oil or sauce", "2d6", "1.5", 10_000),
      TreasureObjectType.new("small amphorae of preserved fish", "1d3", "4.5", 5000),
      TreasureObjectType.new("small amphorae of preserved meat", "1d3", 5, 5000),
      TreasureObjectType.new("crates of glassware", "1d2", "7.5", 5000),
      TreasureObjectType.new("ingots of common metals", "3d6", 1, 500),
      CP_LOT,
      CP_LOT,
      CP_LOT,
      CP_LOT,
      CP_LOT,
      CP_LOT,
      CP_LOT,
      SP_FROM_CP,
    ].freeze
    CP_HORDE = TreasureObjectType.new("copper pieces", 10_000, 0.01, 1).freeze
    SP_LOT = TreasureObjectType.new("silver pieces", 1000, 0.1, 1).freeze
    GP_FROM_SP = TreasureObjectType.new("gold pieces", 100, 1, 1).freeze
    SP_GOODS_TABLE = [
      CP_HORDE,
      TreasureObjectType.new("bundles of common fur pelts", "2d6", 15, 3000),
      TreasureObjectType.new("rolls of woven textiles", "1d6", 30, 4000),
      TreasureObjectType.new("jars of dyes and pigments", "1d3", 50, 5000),
      TreasureObjectType.new("bags of loose herbs", "1d2", 75, 5000),
      TreasureObjectType.new("bags of clothing", "1d2", 75, 5000),
      TreasureObjectType.new("crates of tools", "1d2", 75, 5000),
      TreasureObjectType.new("crates of armor and weapons", 1, 110, 5000),
      TreasureObjectType.new("common animal horns", "4d8", "1d10", ->(instance) { 1000 * instance.gold_value / 10 }),
      TreasureObjectType.new("captured laborers", "1d4", 40, 15_000),
      TreasureObjectType.new("captured domestic servant", 1, 100, 15_000),
      SP_LOT,
      SP_LOT,
      SP_LOT,
      SP_LOT,
      SP_LOT,
      SP_LOT,
      SP_LOT,
      SP_LOT,
      GP_FROM_SP,
    ].freeze
    SP_FROM_EP = TreasureObjectType.new("silver pieces", 5000, 0.1, 1).freeze
    EP_LOT = TreasureObjectType.new("electrum pieces", 1000, 0.5, 1).freeze
    GP_FROM_EP = TreasureObjectType.new("gold pieces", 500, 1, 1).freeze
    EP_GOODS_TABLE = [
      SP_FROM_EP,
      TreasureObjectType.new("bottles of fine wine", "2d100", 5, 20),
      TreasureObjectType.new("rugs of common fur pelts", "3d12", "2d4*5", lambda { |instance|
        1000 * instance.gold_value / 25
      }),
      TreasureObjectType.new("common bird feathers", "2d4*500", "1d3*0.1", 7),
      TreasureObjectType.new("bundles of large common fur", "3d4", "1d8*15", lambda { |instance|
        1000 * instance.gold_value / 30
      }),
      TreasureObjectType.new("uncommon animal horns", "1d12", "3d4*10", lambda { |instance|
        1000 * instance.gold_value / 40
      }),
      TreasureObjectType.new("collections of common books", "1d4", "1d3*100", lambda { |instance|
        1000 * instance.gold_value / 40
      }),
      TreasureObjectType.new("bundles of large uncommon fur pelts", "1d3", "2d4*50", lambda { |instance|
        1000 * instance.gold_value / 50
      }),
      TreasureObjectType.new("captured {SP_PRISONER_TYPE_TABLE}", "1d3", "1d4*100", 15_000),
      EP_LOT,
      EP_LOT,
      EP_LOT,
      EP_LOT,
      EP_LOT,
      EP_LOT,
      EP_LOT,
      EP_LOT,
      EP_LOT,
      EP_LOT,
      GP_FROM_EP,
    ].freeze
    SP_PRISONER_TYPE_TABLE = %w[craftsman merchant].freeze

    SP_FROM_GP = TreasureObjectType.new("silver pieces", 10_000, 0.1, 1).freeze
    GP_LOT = TreasureObjectType.new("gold pieces", 1000, 1, 1).freeze
    PP_FROM_GP = TreasureObjectType.new("platinum pieces", 200, 5, 1).freeze
    GP_GOODS_TABLE = [
      SP_FROM_GP,
      TreasureObjectType.new("metamphorae filled with components", "5d6", 60, lambda { |instance|
        1000 * instance.gold_value / 60
      }),
      TreasureObjectType.new("fresh monster carcasses with souls", "1d6", "1d10*50", lambda { |instance|
        1000 * instance.gold_value / 60
      }),
      TreasureObjectType.new("monster feathers", "1d12*14", "3d6", ->(instance) { 1000 * instance.gold_value / 80 }),
      TreasureObjectType.new("monster horns", "1d8", "1d8*50", ->(instance) { 1000 * instance.gold_value / 80 }),
      TreasureObjectType.new("bundle of rare fur pelt", "1d3", "2d4*100", lambda { |instance|
        1000 * instance.gold_value / 100
      }),
      TreasureObjectType.new("pieces of elephant ivory", "2d20", "1d100", lambda { |instance|
        1000 * instance.gold_value / 100
      }),
      TreasureObjectType.new("stuffed and mounted trophies", "1d3", "2d4*100", lambda { |instance|
        1000 * instance.gold_value / 100
      }),
      TreasureObjectType.new("amphorae of spices", "4d4", 100, 1000),
      TreasureObjectType.new("crates of fine porcelain", "1d3", 500, 5000),
      TreasureObjectType.new("ingots of precious metals", "4d10", 50, 500),
      TreasureObjectType.new("rugs of large common fur", "4d6", "1d4*30", lambda { |instance|
        1000 * instance.gold_value / 150
      }),
      TreasureObjectType.new("captured {GP_PRISONER_TYPE_TABLE}", 1, "2d4*200", 15_000),
      GP_LOT,
      GP_LOT,
      GP_LOT,
      GP_LOT,
      GP_LOT,
      GP_LOT,
      PP_FROM_GP,
    ].freeze
    GP_PRISONER_TYPE_TABLE = %w[equerry lady-in-waiting hetaera odalisque].freeze

    GP_FROM_PP = TreasureObjectType.new("gold pieces", 5000, 1, 1).freeze
    PP_LOT = TreasureObjectType.new("platinum pieces", 1000, 5, 1).freeze
    PP_GOODS_TABLE = [
      GP_FROM_PP,
      TreasureObjectType.new("rolls of silk", "4d6+1", 333, 1000),
      TreasureObjectType.new("rare books", "6d10", 150, 500),
      TreasureObjectType.new("capes of common fur", "5d10", "1d6*50", 1000),
      TreasureObjectType.new("rugs of large uncommon fur", "2d6+1", "1d4*250", lambda { |instance|
        1000 * instance.gold_value / 250
      }),
      TreasureObjectType.new("pieces of rare horns", "2d12", "1d4*150", lambda { |instance|
        1000 * instance.gold_value / 450
      }),
      TreasureObjectType.new("coats of common fur", "2d8", "1d6*150", 1000),
      TreasureObjectType.new("unicorn or narwhale ivory", "4d4", "2d4*100", lambda(&:gold_value)),
      TreasureObjectType.new("captured {PP_PRISONER_TYPE_TABLE}", 1, "2d4*1000", 15_000),
      PP_LOT,
      PP_LOT,
      PP_LOT,
      PP_LOT,
      PP_LOT,
      PP_LOT,
      PP_LOT,
      PP_LOT,
      PP_LOT,
      PP_LOT,
      PP_LOT,
    ].freeze
    PP_PRISONER_TYPE_TABLE = %w[squire damsel gladiator concubine].freeze

    ORNAMENTAL_TABLE = { # Close approximation to 2d20 roll on the table
      1 => TreasureObjectType.new("{GEMS_10GP}", 1, 10, 1).freeze,
      7 => TreasureObjectType.new("{GEMS_25GP}", 1, 25, 1).freeze,
      10 => TreasureObjectType.new("{GEMS_50GP}", 1, 50, 1).freeze,
    }.freeze
    ORNAMENTAL_GOODS_TABLE = [
      TreasureObjectType.new("silver arrows", "1d12", 5, 8),
      TreasureObjectType.new("pouches of {HERBS_5GP}", "1d12", 5, 167),
      TreasureObjectType.new("pouches of {HERBS_10GP}", "1d6", 10, 167),
      TreasureObjectType.new("pouches of {HERBS_10GP}", "1d6", 10, 167),
      TreasureObjectType.new("pouches of horsetail", "1d4", 15, 167),
      TreasureObjectType.new("vials of holy water", "1d2", 25, 167),
      ORNAMENTAL_TABLE,
      ORNAMENTAL_TABLE,
      ORNAMENTAL_TABLE,
      ORNAMENTAL_TABLE,
      ORNAMENTAL_TABLE,
      ORNAMENTAL_TABLE,
    ].freeze

    GEM_TABLE = {
      2 => TreasureObjectType.new("{GEMS_10GP}", 1, 10, 1).freeze,
      5 => TreasureObjectType.new("{GEMS_25GP}", 1, 25, 1).freeze,
      8 => TreasureObjectType.new("{GEMS_50GP}", 1, 50, 1).freeze,
      11 => TreasureObjectType.new("{GEMS_75GP}", 1, 75, 1).freeze,
      14 => TreasureObjectType.new("{GEMS_100GP}", 1, 100, 1).freeze,
      16 => TreasureObjectType.new("{GEMS_250GP}", 1, 250, 1).freeze,
      18 => TreasureObjectType.new("{GEMS_500GP}", 1, 500, 1).freeze,
      19 => TreasureObjectType.new("{GEMS_750GP}", 1, 750, 1).freeze,
      20 => TreasureObjectType.new("{GEMS_1000GP}", 1, 1000, 1).freeze,
    }.freeze
    MULTIPLE_ORNAMENTALS_TABLE = ORNAMENTAL_TABLE.transform_values do |lot|
      TreasureObjectType.new(lot.description, "2d6", lot.value_dice, lot.coin_weight).freeze
    end.freeze
    GEM_GOODS_TABLE = [
      TreasureObjectType.new("set of superior thieves’ tools", 1, 200, 167),
      TreasureObjectType.new("engraved teeth", "1d4", "2d6*10", 167),
      TreasureObjectType.new("vials of rare perfume", "1d3", "1d6*25", 167),
      TreasureObjectType.new("sticks of rare incense", "2d10", "5d6", 10),
      GEM_TABLE,
      GEM_TABLE,
      GEM_TABLE,
      MULTIPLE_ORNAMENTALS_TABLE,
      MULTIPLE_ORNAMENTALS_TABLE,
      MULTIPLE_ORNAMENTALS_TABLE,
    ].freeze

    BRILLIANT_TABLE = {
      2 => TreasureObjectType.new("{GEMS_500GP}", 1, 500, 1).freeze,
      3 => TreasureObjectType.new("{GEMS_750GP}", 1, 750, 1).freeze,
      4 => TreasureObjectType.new("{GEMS_1000GP}", 1, 1000, 1).freeze,
      6 => TreasureObjectType.new("{GEMS_1500GP}", 1, 1500, 1).freeze,
      9 => TreasureObjectType.new("{GEMS_2000GP}", 1, 2000, 1).freeze,
      13 => TreasureObjectType.new("{GEMS_4000GP}", 1, 4000, 1).freeze,
      17 => TreasureObjectType.new("{GEMS_6000GP}", 1, 6000, 1).freeze,
      19 => TreasureObjectType.new("{GEMS_8000GP}", 1, 8000, 1).freeze,
      20 => TreasureObjectType.new("{GEMS_10000GP}", 1, 10_000, 1).freeze,
    }.freeze
    MULTIPLE_GEMS_TABLE = GEM_TABLE.transform_values do |lot|
      TreasureObjectType.new(lot.description, "2d6", lot.value_dice, lot.coin_weight).freeze
    end.freeze
    BRILLIANT_GOODS_TABLE = [
      TreasureObjectType.new("jade carvings of heroes, monsters, and gods", "2d20", 200, 28),
      TreasureObjectType.new("sets of masterwork thieves’ tools", "1d4", 1600, 167),
      TreasureObjectType.new("opal cameo portraits of historical figures and aristocrats", "2d4", 800, 28),
      TreasureObjectType.new("amethyst cylinder seals depicting religious scenes", "1d6", 1200, 28),
      BRILLIANT_TABLE,
      BRILLIANT_TABLE,
      MULTIPLE_GEMS_TABLE,
      MULTIPLE_GEMS_TABLE,
    ].freeze

    HERBS_5GP = %w[lungwort willowbark].freeze
    HERBS_10GP = ["birthwort", "comfrey", "goldenrod", "woundwort", "aloe", "belladonna", "bitterwood",
                  "blessed thistle", "wolfsbane"].freeze

    GEMS_10GP = %w[azurite hematite malachite obsidian quartz].freeze
    GEMS_25GP = ["agate", "lapis lazuli", "tiger eye", "turquoise"].freeze
    GEMS_50GP = %w[bloodstone crystal citrine jasper moonstone onyx].freeze
    GEMS_75GP = %w[carnelian chalcedony sardonx zircon].freeze
    GEMS_100GP = %w[amber amethyst coral jade jet tourmaline].freeze
    GEMS_250GP = %w[garnet pearl spinel].freeze
    GEMS_500GP = %w[aquamarine alexandrite topaz].freeze
    GEMS_750GP = ["opal", "star ruby", "star sapphire", "sunset amethyst", "imperial topaz"].freeze
    GEMS_1000GP = ["black sapphire", "diamond", "emerald", "jacinth", "ruby"].freeze
    GEMS_1500GP = ["amber with preserved extinct creatures", "whorled nephrite jade", "blue diamond"].freeze
    GEMS_2000GP = ["black pearl", "baroque pearl", "crystal geode"].freeze
    GEMS_4000GP = ["facet cut imperial topaz", "flawless diamond"].freeze
    GEMS_6000GP = ["facet cut star sapphire", "facet cut star ruby"].freeze
    GEMS_8000GP = ["flawless facet cut diamond", "flawless facet cut emerald", "flawless facet cut ruby",
                   "flawless facet cut jacinth"].freeze
    GEMS_10000GP = ["flawless facet cut black sapphire", "flawless facet cut blue diamond"].freeze

    TRINKET_TABLE = { # Close approximation to 1d20 roll on the table
      1 => TreasureObjectType.new("{JEWELRY_10}", 1, "2d20", 167).freeze,
      7 => TreasureObjectType.new("{JEWELRY_25}", 1, "2d10*10", 167).freeze,
      10 => TreasureObjectType.new("{JEWELRY_40}", 1, "2d4*100", 167).freeze,
    }.freeze
    TRINKET_GOODS_TABLE = [
      TreasureObjectType.new("bone fetishes and figurines", "3d6", "1d20", 167),
      TreasureObjectType.new("glass eyes, lenses, or prisms", "2d6", "1d6*10", 167),
      TreasureObjectType.new("items of masterwork quality", "1d4", "70+5d6", 167),
      TreasureObjectType.new("silver holy/unholy symbols", "1d4", "2d8*10", 167),
      TRINKET_TABLE,
      TRINKET_TABLE,
      TRINKET_TABLE,
      TRINKET_TABLE,
      TRINKET_TABLE,
      TRINKET_TABLE,
    ].freeze

    JEWELRY_TABLE = {
      2 => TreasureObjectType.new("{JEWELRY_10}", 1, "2d20", 167).freeze,
      5 => TreasureObjectType.new("{JEWELRY_25}", 1, "2d10*10", 167).freeze,
      8 => TreasureObjectType.new("{JEWELRY_40}", 1, "2d4*100", 167).freeze,
      14 => TreasureObjectType.new("{JEWELRY_70}", 1, "2d6*100", 167).freeze,
      16 => TreasureObjectType.new("{JEWELRY_80}", 1, "3d6*100", 167).freeze,
      19 => TreasureObjectType.new("{JEWELRY_95}", 1, "1d4*1000", 167).freeze,
      20 => TreasureObjectType.new("{JEWELRY_100}", 1, "2d4*1000", 167).freeze,
    }.freeze
    MULTIPLE_TRINKETS_TABLE = TRINKET_TABLE.transform_values do |lot|
      TreasureObjectType.new(lot.description, "1d8", lot.value_dice, lot.coin_weight).freeze
    end
    JEWELRY_GOODS_TABLE = [
      MULTIPLE_TRINKETS_TABLE,
      TreasureObjectType.new("capes of large animal fur", 1, "2d4*200", 1000),
      TreasureObjectType.new("vials of common poison", "1d10", "2d6*25", 167),
      TreasureObjectType.new("statuettes", "1d3", "1d10*100", 83),
      TreasureObjectType.new("items of masterwork quality", "1d2", "2d6*100", 167),
      JEWELRY_TABLE,
      JEWELRY_TABLE,
      JEWELRY_TABLE,
      JEWELRY_TABLE,
      JEWELRY_TABLE,
    ].freeze

    REGALIA_TABLE = {
      3 => TreasureObjectType.new("{JEWELRY_95}", 1, "1d4*1000", 167).freeze,
      4 => TreasureObjectType.new("{JEWELRY_100}", 1, "2d4*1000", 167).freeze,
      9 => TreasureObjectType.new("{JEWELRY_125}", 1, "3d4*1000", 167).freeze,
      13 => TreasureObjectType.new("{JEWELRY_145}", 1, "2d8*1000", 167).freeze,
      15 => TreasureObjectType.new("{JEWELRY_155}", 1, "3d6*1000", 167).freeze,
      17 => TreasureObjectType.new("{JEWELRY_165}", 1, "2d20*1000", 167).freeze,
      19 => TreasureObjectType.new("{JEWELRY_175}", 1, "1d4*10_000", 167).freeze,
      20 => TreasureObjectType.new("{JEWELRY_180}", 1, "1d8*10_000", 167).freeze,
    }.freeze
    MULTIPLE_JEWELRY_TABLE = JEWELRY_TABLE.transform_values do |lot|
      TreasureObjectType.new(lot.description, "4d8", lot.value_dice, lot.coin_weight).freeze
    end
    REGALIA_GOODS_TABLE = [
      MULTIPLE_JEWELRY_TABLE,
      TreasureObjectType.new("capes of rare animal or monster fur", "1d6", "1d6*1000", 1000),
      TreasureObjectType.new("coats of large common or uncommon animal fur", "1d4", "(1d6+1)*1000", 1000),
      TreasureObjectType.new("vials of rare poison", "2d10", "4d4*100", 167),
      TreasureObjectType.new("alabaster and jet game pieces with jeweled eyes", "2d10", "3d6*100", 27),
      TreasureObjectType.new("coat of rare animal or monster fur", 1, "2d10*1000", 1000),
      TreasureObjectType.new("carved ivory figurines", "1d8", "1d4*1000", 27),
      TreasureObjectType.new("platinum reliquaries with crystal panes", "1d4", "1d8*1000", 27),
      REGALIA_TABLE,
      REGALIA_TABLE,
      REGALIA_TABLE,
      REGALIA_TABLE,
    ].freeze

    JEWELRY_10 = ["bones", "scrimshaw", "beast parts"].freeze
    JEWELRY_25 = ["glass", "shells", "wrought copper", "wrought brass", "wrought bronze"].freeze
    JEWELRY_40 = ["fine wood", "porcelain", "wrought silver"].freeze
    JEWELRY_70 = ["alabaster", "chryselephantine", "ivory", "wrought gold"].freeze
    JEWELRY_80 = ["carved jade", "wrought platinum"].freeze
    JEWELRY_95 = ["wrought orichalcum", "silver studded with turquoise", "moonstone", "opal"].freeze
    JEWELRY_100 = ["silver studded with jet", "silver studded with amber", "silver studded with pearl"].freeze
    JEWELRY_125 = ["gold studded with topaz", "gold studded with jacinth", "gold studded with ruby"].freeze
    JEWELRY_145 = ["platinum studded with diamond", "platinum studded with sapphire",
                   "platinum studded with emerald"].freeze
    JEWELRY_155 = ["electrum pendant with pearls and star rubies", "silver pendant with pearls and star rubies"].freeze
    JEWELRY_165 = ["gold pendant with diamonds and sapphires", "platinum pendant with diamonds and sapphires"].freeze
    JEWELRY_175 = ["gold encrusted with flawless facet cut diamonds"].freeze
    JEWELRY_180 = ["platinum encrusted with flawless black sapphires", "platinum encrusted with blue diamonds"].freeze
  end
end
