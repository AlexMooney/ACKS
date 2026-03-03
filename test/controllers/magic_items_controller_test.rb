# frozen_string_literal: true

require "test_helper"

class MagicItemsControllerTest < ActionDispatch::IntegrationTest
  test "generate with no params renders form" do
    get generate_magic_items_url
    assert_response :success
    assert_select "form"
    assert_select "input[name='common']"
  end

  test "generate with quantities returns results" do
    get generate_magic_items_url, params: { common: 3, uncommon: 1 }
    assert_response :success
    assert_select "form"
    assert_select ".magic-items-results"
  end

  test "generate with all zeros renders form without results" do
    get generate_magic_items_url, params: { common: 0, uncommon: 0, rare: 0, very_rare: 0, legendary: 0 }
    assert_response :success
    assert_select ".magic-items-results", false
  end
end
