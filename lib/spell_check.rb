# frozen_string_literal: true

module SpellCheck
  def spell_check(key, keys, spell_checker: nil)
    return key if keys.include? key

    spell_checker ||= DidYouMean::SpellChecker.new(dictionary: keys)
    spell_check = spell_checker.correct(key)
    if spell_check.any?
      puts "Assuming you meant `#{spell_check.first}`.  Valid choices: `#{keys.join '`, `'}`."
      spell_check.first
    else
      puts "Didn't find `#{key}`.  Valid choices: `#{keys.join '`, `'}`."
      exit
    end
  end
end
