# frozen_string_literal: true

class Character < ApplicationRecord
  has_many :magic_item_instances, as: :owner, dependent: :destroy
end
