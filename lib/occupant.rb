require_relative 'random_weighted'

class Occupant
  include RandomWeighted

  attr_accessor :type, :subtype, :occupation
  def initialize(type: nil, subtype: nil)
    self.type = type || random_weighted(GENERAL_OCCUPATIONS)
    self.subtype = subtype || subtype_from_type
  end

  def to_s
    "#{type} #{subtype ? "(#{subtype})" : ""}".strip
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
  }

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
    unskilled_laborer: 100,
  }
  DEPENDANT_OCCUPATIONS = {
    child: 90,
    elderly: 100,
  }

  private
    def subtype_from_type
      case type
      when :laborer
        random_weighted(LABORER_SUBTYPES)
      when :dependent
        random_weighted(DEPENDANT_OCCUPATIONS)
      end
    end
end
