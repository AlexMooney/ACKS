# frozen_string_literal: true

class MagicItemsController < ApplicationController
  RARITIES = %i[common uncommon rare very_rare legendary].freeze

  def generate
    @quantities = RARITIES.index_with { |r| params[r].to_i }

    if @quantities.values.any?(&:positive?)
      @magic_items = TTMagicItems.new(**@quantities)
    end
  end
end
