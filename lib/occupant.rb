# frozen_string_literal: true

require_relative "random_weighted"

class Occupant
  include RandomWeighted

  attr_accessor :type, :subtype, :occupation

  def initialize(type: nil, subtype: nil)
    self.type = type || random_weighted(GENERAL_OCCUPATIONS)
    self.subtype = subtype || subtype_from_type
  end

  def to_s
    "#{type} #{subtype ? "(#{subtype})" : ''}".strip
  end

  GENERAL_OCCUPATIONS = {
    laborer: 26,
    apprentice_crafter: 45,
    journeyman_crafter: 55,
    master_crafter: 60,
    apprentice_merchant: 68,
    licensed_merchant: 72,
    master_merchant: 74,
    specialist: 76,
    hosteller: 81,
    entertainer: 83,
    thief: 85,
    legionary: 88,
    mercenary: 91,
    fighter: 93,
    minor_ecclasiastic: 95,
    cleric: 97,
    minor_magician: 98,
    mage: 99,
    patrician: 100,
  }.freeze

  LABORER_SUBTYPES = {
    barber: 3,
    bath_attendant: 6,
    bricklayer: 8,
    cook: 19,
    dockworker: 22,
    launderer: 25,
    rower: 32,
    gongfarmer: 34,
    hawker: 40,
    stablehand: 48,
    maidservant: 51,
    prostitute: 59,
    ratcatcher: 60,
    roofer: 61,
    scullion: 73,
    sawyer: 75,
    teamster: 78,
    tavernworker: 90,
    unskilled: 100,
  }.freeze
  ARTISAN_SUBTYPES = {
    apothecary: 2,
    armorer: 4,
    baker: 6,
    blacksmith: 8,
    bookbinder: 9,
    bowyer: 10,
    fletcher: 11,
    brewer: 14,
    brickmaker: 16,
    butcher: 21,
    cabinetmaker: 22,
    candlemaker: 25,
    capper: 26,
    hatter: 27,
    carpenter: 28,
    chaloner: 30,
    tapicer: 31,
    clothmaker: 37,
    cobbler: 38,
    cordwainer: 39,
    confectioner: 41,
    cooper: 42,
    coppersmith: 44,
    ropemaker: 45,
    decorative_artist: 48,
    florist: 49,
    gemcutter: 50,
    glassworker: 52,
    goldsmith: 56,
    hornworker: 58,
    illuminator: 60,
    jeweler: 61,
    locksmith: 62,
    mason: 64,
    parchmentmaker: 65,
    perfumer: 66,
    potter: 69,
    saddler: 70,
    fuster: 71,
    scribe: 75,
    shipwright: 76,
    silversmith: 77,
    spinner: 83,
    tailor: 86,
    seamstress: 89,
    tanner: 92,
    tawer: 93,
    taxidermist: 94,
    tinker: 95,
    toymaker: 96,
    wainwright: 97,
    weaponsmith: 99,
    wheelwright: 100,
  }.freeze
  MERCHANT_OCCUPATIONS = {
    bookseller: 1,
    chandler: 6,
    coppermonger: 8,
    cornmonger: 20,
    draper: 31,
    fishmonger: 38,
    fripperer: 44,
    furrier: 46,
    greengrocer: 48,
    horsemonger: 52,
    ironmonger: 61,
    lawyer: 66,
    lumbermonger: 75,
    mercer: 80,
    oilmonger: 82,
    peltmonger: 88,
    poulterer: 91,
    salter: 95,
    vintner: 100,
  }.freeze
  DEPENDANT_SUBTYPES = {
    child: 90,
    elderly: 100,
  }.freeze

  private

  def subtype_from_type
    case type
    when :laborer
      random_weighted(LABORER_SUBTYPES)
    when :dependent
      random_weighted(DEPENDANT_SUBTYPES)
    when :apprentice_crafter, :journeyman_crafter, :master_crafter
      random_weighted(ARTISAN_SUBTYPES)
    when :apprentice_merchant, :licensed_merchant, :master_merchant
      random_weighted(MERCHANT_OCCUPATIONS)
    end
  end
end
