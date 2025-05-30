# frozen_string_literal: true

class Treasure
  module SpecialTreasureTables
    CP_GOODS_TABLE = [
      ["bags of grain or vegetables (5sp / 4 st)", "2d20"],
      ["bricks of salt (7cp / 1/2 st)",                  "4d6*10"],
      ["amphorae of beer (1gp / 7 st)",                  "2d10"],
      ["crates of terra-cotta pottery (5sp / 3 1/2 st)", "6d6"],
      ["bundles of hardwood logs (1gp / 6 st)",          "2d10"],
      ["amphorae of wine and spirits (1gp / 5 st)",      "2d10"],
      ["wheels of cheese (25cp / 1/2 st)",               "4d20"],
      ["amphorae of oil or sauce (15sp / 10 st)",        "2d6"],
      ["small amphorae of preserved fish (4.5gp / 5 st)", "1d3"],
      ["small amphorae of preserved meat (5gp / 5 st)",  "1d3"],
      ["crates of glassware (7.5gp / 5 st)",             "1d2"],
      ["ingots of common metals (1gp / 1/2 st)",         "3d6"],
      ["cp",                                              "1000"],
      ["cp",                                              "1000"],
      ["cp",                                              "1000"],
      ["cp",                                              "1000"],
      ["cp",                                              "1000"],
      ["cp",                                              "1000"],
      ["cp",                                              "1000"],
      ["sp",                                              "100"],
    ].freeze
    SP_GOODS_TABLE = [
      ["cp", "10000"],
      ["bundles of common fur pelts (15gp / 3 st)",                  "2d6"],
      ["rolls of woven textiles (30gp / 4 st)",                      "1d6"],
      ["jars of dyes and pigments (50gp / 5 st)",                    "1d3"],
      ["bags of loose herbs (75gp / 5 st)",                          "1d2"],
      ["bags of clothing (75gp / 5 st)",                             "1d2"],
      ["crates of tools (75gp / 5 st)",                              "1d2"],
      ["crates of armor and weapons (110gp / 5 st)",                 "1"],
      ["common animal horns worth {1d10}gp each (1 st per 10gp)", "4d8"],
      ["captured laborers (40gp ransom)",                            "1d4"],
      ["captured domestic servant (100gp ransom)",                   "1"],
      ["sp",                                                          "1000"],
      ["sp",                                                          "1000"],
      ["sp",                                                          "1000"],
      ["sp",                                                          "1000"],
      ["sp",                                                          "1000"],
      ["sp",                                                          "1000"],
      ["sp",                                                          "1000"],
      ["sp",                                                          "1000"],
      ["gp",                                                          "100"],
    ].freeze
    EP_GOODS_TABLE = [
      ["sp",                                                                        "5000"],
      ["bottles of fine wine worth 5gp (5 bottles / st)",                           "2d100"],
      ["rugs of common fur pelts worth {2d4*5}gp each (1 st per 25gp)",          "3d12"],
      ["common bird feathers worth {1d3}sp (1 st / 150 feathers)",               "2d4*500"],
      ["bundles of large common fur worth {1d8*15} (1 st / 30gp)",               "3d4"],
      ["uncommon animal horns worth {3d4*10} (1 st / 40gp)",                     "1d12"],
      ["collections of common books worth {1d3*100} each (1 st / 40 gp)",        "1d4"],
      ["bundles of large uncommon fur pelts worth {2d4*50} each (1 st / 50 gp)", "1d3"],
      ["captured {EP_PRISONER_TABLE} worth {1d4*100} each", "1d3"],
      ["ep",                                                                        1000],
      ["ep",                                                                        1000],
      ["ep",                                                                        1000],
      ["ep",                                                                        1000],
      ["ep",                                                                        1000],
      ["ep",                                                                        1000],
      ["ep",                                                                        1000],
      ["ep",                                                                        1000],
      ["ep",                                                                        1000],
      ["ep",                                                                        1000],
      ["gp",                                                                        500],
    ].freeze
    EP_PRISONER_TABLE = %w[craftsman merchant].freeze

    GP_GOODS_TABLE = [
      ["sp",                                                         "10000"],
      ["metamphorae filled with components (1 st / 60gp)",           "5d6"],
      ["fresh monster carcasses with souls worth {1d10*50}gp",    "1d6"],
      ["monster feathers worth {3d6}gp (1 st / 80gp)",            "1d12*14"],
      ["monster horns worth {1d8*50}gp (1 st / 80gp)",            "1d8"],
      ["bundle of rare fur pelt worth {2d4*100}gp (1 st / 100 gp)", "1d3"],
      ["pieces of elephant ivory worth {1d100}gp (1 st / 100 gp)",  "2d20"],
      ["stuffed and mounted trophies worth {2d4*100}gp each (1 st / 100gp)", "1d3"],
      ["amphorae of spices (100gp / 1 st)",                          "4d4"],
      ["creates of fine porcelain worth 500gp (5 st)",               "1d3"],
      ["ingots of precious metals worth 50 gp (1/2 st)",             "4d10"],
      ["rugs of large common fur worth {1d4*30} (1 st / 150gp)", "4d6"],
      ["captured {GP_PRISONER_TYPE_TABLE} worth {2d4*200}", "1"],
      ["gp",                                                         "1000"],
      ["gp",                                                         "1000"],
      ["gp",                                                         "1000"],
      ["gp",                                                         "1000"],
      ["gp",                                                         "1000"],
      ["gp",                                                         "1000"],
      ["pp",                                                         "200"],
    ].freeze

    GP_PRISONER_TYPE_TABLE = %w[equerry lady-in-waiting hetaera odalisque].freeze

    PP_GOODS_TABLE = [
      ["gp",                                                            "5000"],
      ["rolls of silk worth (333gp / 1 st)",                            "4d6+1"],
      ["rare books (150gp / 1/2 st)",                                   "6d10"],
      ["capes of common fur worth {1d6*50} (1 st)",                  "5d10"],
      ["rugs of large uncommon fur worth {1d4*250} (1 st / 250gp)",  "2d6+1"],
      ["pieces of rare horns worth {1d4*150} (1 st / 450gp)",        "2d12"],
      ["coats of common fur worth {1d6*150}gp (1 st)",               "2d8"],
      ["unicorn or narwhale ivory worth {2d4*100} (1 st / 1000 gp)", "4d4"],
      ["captured {PP_PRISONER_TYPE_TABLE} worth {2d4*1000}", "1"],
      ["pp",                                                            "1000"],
      ["pp",                                                            "1000"],
      ["pp",                                                            "1000"],
      ["pp",                                                            "1000"],
      ["pp",                                                            "1000"],
      ["pp",                                                            "1000"],
      ["pp",                                                            "1000"],
      ["pp",                                                            "1000"],
      ["pp",                                                            "1000"],
      ["pp",                                                            "1000"],
      ["pp",                                                            "1000"],
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
