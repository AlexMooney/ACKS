# frozen_string_literal: true

class CharactersController < ApplicationController
  before_action :set_character, only: %i[show edit update destroy]

  # GET /characters or /characters.json
  def index
    @characters = Character.all
  end

  # GET /characters/1 or /characters/1.json
  def show; end

  # GET /characters/new
  def new
    @character = Character.new
  end

  # POST /characters/generate
  INTEGER_OVERRIDE_KEYS = %i[level template str int wil dex con cha height_inches weight_lbs].freeze

  def generate
    overrides = character_params.to_h.reject { |_, v| v.blank? }.symbolize_keys
    INTEGER_OVERRIDE_KEYS.each { |k| overrides[k] = overrides[k].to_i if overrides[k] }
    character_class = overrides.delete(:character_class)
    class_type = overrides.delete(:class_type)
    level = overrides.delete(:level) || 1

    @character = CharacterGenerator.new(
      character_class: character_class,
      class_type: class_type,
      level: level,
      overrides: overrides,
    ).generate
    render :new, status: :unprocessable_entity
  end

  # GET /characters/1/edit
  def edit; end

  # POST /characters or /characters.json
  def create
    @character = Character.new(character_params)

    respond_to do |format|
      if @character.save
        format.html { redirect_to @character, notice: "Character was successfully created." }
        format.json { render :show, status: :created, location: @character }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @character.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /characters/1 or /characters/1.json
  def update
    respond_to do |format|
      if @character.update(character_params)
        format.html { redirect_to @character, notice: "Character was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @character }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @character.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /characters/1 or /characters/1.json
  def destroy
    @character.destroy!

    respond_to do |format|
      format.html { redirect_to characters_path, notice: "Character was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_character
    @character = Character.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def character_params
    params.expect(character: %i[name title level character_class class_type template ethnicity sex
                                alignment str int wil dex con cha build height_inches weight_lbs eye_color skin_color hair_color hair_texture features])
  end
end
