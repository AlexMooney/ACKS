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

    CP_LOT = TreasureObjectType.new("copper pieces", "1000", "0.01", 1).freeze
    SP_FROM_CP = TreasureObjectType.new("silver pieces", "100", "0.1", 1).freeze
    CP_GOODS_TABLE = [
      TreasureObjectType.new("bags of grain or vegetables", "2d20", "0.5", 4_000),
      TreasureObjectType.new("bricks of salt", "4d6*10", "0.07", 500),
      TreasureObjectType.new("amphorae of beer", "2d10", "1", 7000),
      TreasureObjectType.new("crates of terra-cotta pottery", "6d6", "0.5", 3500),
      TreasureObjectType.new("bundles of hardwood logs", "2d10", "1", 6000),
      TreasureObjectType.new("amphorae of wine and spirits", "2d10", "1", 5000),
      TreasureObjectType.new("wheels of cheese", "4d20", "0.25", 500),
      TreasureObjectType.new("amphorae of oil or sauce", "2d6", "1.5", 10_000),
      TreasureObjectType.new("small amphorae of preserved fish", "1d3", "4.5", 5000),
      TreasureObjectType.new("small amphorae of preserved meat", "1d3", "5", 5000),
      TreasureObjectType.new("crates of glassware", "1d2", "7.5", 5000),
      TreasureObjectType.new("ingots of common metals", "3d6", "1", 500),
      CP_LOT,
      CP_LOT,
      CP_LOT,
      CP_LOT,
      CP_LOT,
      CP_LOT,
      CP_LOT,
      SP_FROM_CP,
    ].freeze
    CP_HORDE = TreasureObjectType.new("copper pieces", "10000", "0.01", 1).freeze
    SP_LOT = TreasureObjectType.new("silver pieces", "1000", "0.1", 1).freeze
    GP_FROM_SP = TreasureObjectType.new("gold pieces", "100", "1", 1).freeze
    SP_GOODS_TABLE = [
      CP_HORDE,
      TreasureObjectType.new("bundles of common fur pelts", "2d6", "15", 3000),
      TreasureObjectType.new("rolls of woven textiles", "1d6", "30", 4000),
      TreasureObjectType.new("jars of dyes and pigments", "1d3", "50", 5000),
      TreasureObjectType.new("bags of loose herbs", "1d2", "75", 5000),
      TreasureObjectType.new("bags of clothing", "1d2", "75", 5000),
      TreasureObjectType.new("crates of tools", "1d2", "75", 5000),
      TreasureObjectType.new("crates of armor and weapons", "1", "110", 5000),
      TreasureObjectType.new("common animal horns", "4d8", "1d10", ->(instance) { 1000 * instance.gold_value / 10 }),
      TreasureObjectType.new("captured laborers", "1d4", "40", 15_000),
      TreasureObjectType.new("captured domestic servant", "1", "100", 15_000),
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
    SP_FROM_EP = TreasureObjectType.new("silver pieces", "5000", "0.1", 1).freeze
    EP_LOT = TreasureObjectType.new("electrum pieces", "1000", "0.5", 1).freeze
    GP_FROM_EP = TreasureObjectType.new("gold pieces", "500", "1", 1).freeze
    EP_GOODS_TABLE = [
      SP_FROM_EP,
      TreasureObjectType.new("bottles of fine wine", "2d100", "5", 20),
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

    SP_FROM_GP = TreasureObjectType.new("silver pieces", "10000", "0.1", 1).freeze
    GP_LOT = TreasureObjectType.new("gold pieces", "1000", "1", 1).freeze
    PP_FROM_GP = TreasureObjectType.new("platinum pieces", "200", "5", 1).freeze
    GP_GOODS_TABLE = [
      SP_FROM_GP,
      TreasureObjectType.new("metamphorae filled with components", "5d6", "60", lambda { |instance|
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
      TreasureObjectType.new("amphorae of spices", "4d4", "100", 1000),
      TreasureObjectType.new("crates of fine porcelain", "1d3", "500", 5000),
      TreasureObjectType.new("ingots of precious metals", "4d10", "50", 500),
      TreasureObjectType.new("rugs of large common fur", "4d6", "1d4*30", lambda { |instance|
        1000 * instance.gold_value / 150
      }),
      TreasureObjectType.new("captured {GP_PRISONER_TYPE_TABLE}", "1", "2d4*200", 15_000),
      GP_LOT,
      GP_LOT,
      GP_LOT,
      GP_LOT,
      GP_LOT,
      GP_LOT,
      PP_FROM_GP,
    ].freeze
    GP_PRISONER_TYPE_TABLE = %w[equerry lady-in-waiting hetaera odalisque].freeze

    GP_FROM_PP = TreasureObjectType.new("gold pieces", "5000", "1", 1).freeze
    PP_LOT = TreasureObjectType.new("platinum pieces", "1000", "5", 1).freeze
    PP_GOODS_TABLE = [
      GP_FROM_PP,
      TreasureObjectType.new("rolls of silk", "4d6+1", "333", 1000),
      TreasureObjectType.new("rare books", "6d10", "150", 500),
      TreasureObjectType.new("capes of common fur", "5d10", "1d6*50", 1000),
      TreasureObjectType.new("rugs of large uncommon fur", "2d6+1", "1d4*250", lambda { |instance|
        1000 * instance.gold_value / 250
      }),
      TreasureObjectType.new("pieces of rare horns", "2d12", "1d4*150", lambda { |instance|
        1000 * instance.gold_value / 450
      }),
      TreasureObjectType.new("coats of common fur", "2d8", "1d6*150", 1000),
      TreasureObjectType.new("unicorn or narwhale ivory", "4d4", "2d4*100", ->(instance) { instance.gold_value }),
      TreasureObjectType.new("captured {PP_PRISONER_TYPE_TABLE}", "1", "2d4*1000", 15_000),
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

    GEMS_TABLE = {
      10 => "10 gp ornamental",
      40 => "50 gp ornamental",
      100 => "1000 gp gem",
      180 => "10000 gp brilliant",
    }.freeze

    JEWELRY_TABLE = [ # TODO
      %w[jewelry 1],
    ].freeze
  end
end
