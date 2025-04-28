# frozen_string_literal: true

module SpellCheck
  def spell_check(key, keys)
    return key if keys.include? key

    spell_check = DidYouMean::SpellChecker.new(dictionary: keys).correct(key)
    if spell_check.any?
      puts "Assuming you meant `#{spell_check.first}`."
      spell_check.first
    else
      puts "Didn't find `#{missing_key}`.  Valid choices: `#{keys.join '`, `'}`."
      exit
    end
  end
end
