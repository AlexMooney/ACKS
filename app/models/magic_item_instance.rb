# frozen_string_literal: true

class MagicItemInstance < ApplicationRecord
  belongs_to :magic_item
  belongs_to :owner, polymorphic: true, optional: true

  def display_name
    override_name || magic_item.name
  end

  def display_description
    override_description || magic_item.description
  end
end
