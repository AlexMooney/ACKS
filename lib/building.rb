require_relative 'occupant'
require_relative 'dice'
require_relative 'building/cot'
require_relative 'building/townhouse'
require_relative 'building/villa'
require_relative 'building/shop'
require_relative 'building/manufactory'
require_relative 'random_weighted'

class Building
  include RandomWeighted

  def self.construct
    size ||= random_weighted(SIZE_WEIGHTS)
    type ||= random_weighted(TYPE_WEIGHTS[size])
    
    type.new(size, type)
  end
  
  attr_accessor :size, :type, :occupants
  def initialize(size, type)
    self.size = size
    self.type = type
    self.occupants = generate_occupants
  end

  def generate_occupants
    []
  end

  def description
    "Size: #{size}, Type: #{type.label}, Occupants (#{occupants.size}): #{occupants.map(&:to_s).join(', ')}"
  end

  private
    def location
      "#{self.size}_#{self.type}"
    end

    SIZE_WEIGHTS = {
      small: 50,
      medium: 75,
      large: 95,
      huge: 100
    }.freeze

    TYPE_WEIGHTS = {
      small: {
        Cot => 100, #55,
        Townhouse => nil,
        Villa => nil,
        # Shop => 60,
        # Shophouse => 84,
        # Manufactory => nil,
        # Depot => 89,
        # Bawdyhouse => 90,
        # Cantina => 97,
        # Inn => nil,
        # Tavern => nil,
        # Bathhouse => nil,
        # Latrine => 98,
        # Shrine => 99,
        # Stables => 100,
      },
      medium: {
        Cot => 50, #35,
        Townhouse => 100, # 70,
        Villa => nil,
        # Shop => 82,
        # Shophouse => 92,
        # Manufactory => nil,
        # Depot => 97,
        # Bawdyhouse => 98,
        # Cantina => 99,
        # Inn => nil,
        # Tavern => nil,
        # Bathhouse => 100,
        # Latrine => nil,
        # Shrine => nil,
        # Stables => nil,
    },
      large: {
        Cot => nil,
        Townhouse => 50, # 10
        Villa => 100, # 20
        # Shop => 35,
        # Shophouse => 40,
        # Manufactory => nil,
        # Depot => 45,
        # Bawdyhouse => 46,
        # Cantina => 53,
        # Inn => 63,
        # Tavern => 88,
        # Bathhouse => 93,
        # Latrine => 94,
        # Shrine => nil,
        # Stables => 100,
    },
      huge: {
        Cot => nil,
        Townhouse => 10, # 10
        Villa => 100 # 65,
        # Shop => nil,
        # Shophouse => nil,
        # Manufactory => 85,
        # Depot => 90,
        # Bawdyhouse => nil,
        # Cantina => nil,
        # Inn => nil,
        # Tavern => nil,
        # Bathhouse => 93,
        # Latrine => 96,
        # Shrine => 100,
        # Stables => nil,
      }
    }.freeze
end
