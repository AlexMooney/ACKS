# frozen_string_literal: true

class Character
  module Descriptions
    module Belongings
      BELONGING_TYPE = %w[arms clothing headware adornments].freeze

      CHAOTIC_ARMS = {
        1 => "Adorned, e.g. Bones, Teeth, Fingers",
        2 => "Bent/Slightly Twisted",
        3 => "Blood-Stained",
        4 => "Dented",
        5 => "Fire-Blackened",
        6 => "Notched, e.g. Damaged/Nicked, Kill Notches",
        7 => "Rusted/Pitted/Tarnished",
        8 => "Scratched, e.g. Damaged, Crude Designs",
      }.freeze

      ANY_ARMS = {
        2 => "Adorned, e.g. Beads, Fabric Strips, Feathers",
        4 => "Dented",
        6 => "Etched",
        8 => "Notched, e.g. Damaged/Nicked, Kill Notches",
        10 => "Well-Maintained",
      }.freeze

      LAWFUL_ARMS = {
        1 => "Adorned, e.g. Pennants, Ribbons",
        2 => "Etched/Enameled",
        3 => "Highly Polished",
        4 => "Well-Maintained",
      }.freeze

      CHAOTIC_CLOTHING = {
        1 => "Absent, e.g. Naked or Partially Naked!",
        2 => "Garish - Clashing Colors, Sickly Colors",
        3 => "Falling Apart",
        4 => "Filthy, e.g. Blood-Stained, Encrusted",
        5 => "Ill-Fitting, e.g. Badly Made, Made for Another Race, Too Large, Too Small",
        6 => "Oddly Chosen, e.g. Sage’s Robe on a Warrior",
      }.freeze

      ANY_CLOTHING = {
        1 => "Adorned, e.g. Beadwork, Decorative Stitching, Tassels",
        2 => "Brightly Colored, e.g. Jester-Like Motley",
        3 => "Poor-Fitting, e.g. Slightly Too Big/Small",
        4 => "Stained - Alchemical Discoloration, Travel-Stained",
      }.freeze

      LAWFUL_CLOTHING = {
        2 => "Adorned, e.g. Fine Embroidery",
        4 => "Bright, Attractive Colors",
        6 => "Luxurious, e.g. Fine Fabrics, Fur-Lined, Silk-Lined",
        8 => "Perfectly Fitted",
        10 => "Well-Maintained",
      }.freeze

      ANY_HEADWARE = {
        1 => "Bandana",
        2 => "Circlet, e.g. Bone, Brass, Iron, Pewter, Vines",
        3 => "Coif",
        4 => "Fabric Cap",
        5 => "Fur Cap",
        6 => "Headband",
        7 => "Hood",
        8 => "Mask, e.g. Animalistic, Caricature, Domino, Featureless, Monstrous, Ritual",
        9 => "Pointy Hat",
        10 => "Skullcap, e.g. Fabric, Iron",
        11 => "Veil",
        12 => "Wide-Brimmed Hat",
      }.freeze

      CHAOTIC_ADORNMENTS = {
        2 => "Belt Hangings - Dead Animals, Hands, Heads",
        4 => "Necklace - Ears, Fingers, Teeth, Unholy Symbol",
      }.freeze

      ANY_ADORNMENTS = {
        1 => "Armbands/Bracers, e.g. Bone, Fabric Strips, Leather, Metal, Wood",
        2 => "Belt, e.g. Braided, Broad, Ornamental Buckle, Studded",
        3 => "Belt Hangings, e.g. Animal Tails, Pouches",
        4 => "Bracelets, e.g. Bone, Fabric Strips, Leather, Metal, Wood",
        5 => "Folding Fan",
        6 => "Necklace, e.g. Beads, Claws/Fangs, Holy Symbol, Locket",
        7 => "Sash",
        8 => "Smoking Pipe",
      }.freeze
    end
  end
end
