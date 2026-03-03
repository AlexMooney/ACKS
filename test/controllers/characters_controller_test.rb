# frozen_string_literal: true

require "test_helper"

class CharactersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @character = characters(:one)
  end

  test "should get index" do
    get characters_url
    assert_response :success
  end

  test "should get new" do
    get new_character_url
    assert_response :success
  end

  test "should create character" do
    assert_difference("Character.count") do
      post characters_url,
           params: { character: { alignment: @character.alignment, build: @character.build, cha: @character.cha,
                                  character_class: @character.character_class, class_type: @character.class_type, con: @character.con, dex: @character.dex, ethnicity: @character.ethnicity, eye_color: @character.eye_color, features: @character.features, hair_color: @character.hair_color, hair_texture: @character.hair_texture, height_inches: @character.height_inches, int: @character.int, level: @character.level, name: @character.name, sex: @character.sex, skin_color: @character.skin_color, str: @character.str, template: @character.template, title: @character.title, weight_lbs: @character.weight_lbs, wil: @character.wil } }
    end

    assert_redirected_to character_url(Character.last)
  end

  test "should show character" do
    get character_url(@character)
    assert_response :success
  end

  test "should get edit" do
    get edit_character_url(@character)
    assert_response :success
  end

  test "should update character" do
    patch character_url(@character),
          params: { character: { alignment: @character.alignment, build: @character.build, cha: @character.cha,
                                 character_class: @character.character_class, class_type: @character.class_type, con: @character.con, dex: @character.dex, ethnicity: @character.ethnicity, eye_color: @character.eye_color, features: @character.features, hair_color: @character.hair_color, hair_texture: @character.hair_texture, height_inches: @character.height_inches, int: @character.int, level: @character.level, name: @character.name, sex: @character.sex, skin_color: @character.skin_color, str: @character.str, template: @character.template, title: @character.title, weight_lbs: @character.weight_lbs, wil: @character.wil } }
    assert_redirected_to character_url(@character)
  end

  test "should destroy character" do
    assert_difference("Character.count", -1) do
      delete character_url(@character)
    end

    assert_redirected_to characters_url
  end
end
