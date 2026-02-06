module ProfanityFilter
  def self.ensure_switch_initialized
    $game_switches ||= Game_Switches.new
    $game_switches[ProfanitySettings::ENABLE_PROFANITY_FILTER] ||= false
  end

  def self.filter(text)
    ensure_switch_initialized
    return text unless $game_switches[ProfanitySettings::ENABLE_PROFANITY_FILTER]  # Check the switch status
    ProfanitySettings::PROFANE_WORDS.each do |word|
      text = text.gsub(/\b#{word}\b/i) { |match| random_replacement(match.length) }
    end
    text
  end

  def self.random_replacement(length)
    replacement = ""
    characters = ["$", "#", "@", "%", "&", "*"]
    length.times { replacement += characters.sample }
    replacement
  end
end

def pbCreateMessageWindow(viewport = nil, skin = nil)
  msgwindow = Window_AdvancedTextPokemon.new("")
  if viewport
    msgwindow.viewport = viewport
  else
    msgwindow.z = 99999
  end
  msgwindow.visible = true
  msgwindow.letterbyletter = true
  msgwindow.back_opacity = MessageConfig::WINDOW_OPACITY
  pbBottomLeftLines(msgwindow, 2)
  $game_temp.message_window_showing = true if $game_temp
  skin = MessageConfig.pbGetSpeechFrame if !skin
  msgwindow.setSkin(skin)

  class << msgwindow
    alias_method :original_text=, :text=

    def text=(value)
      ProfanityFilter.ensure_switch_initialized
      if $game_switches[ProfanitySettings::ENABLE_PROFANITY_FILTER] 
        value = ProfanityFilter.filter(value)
      end
      self.original_text = value
    end
  end

  return msgwindow
end

MenuHandlers.add(:options_menu, :profanity_filter, {
  "name"        => _INTL("Profanity Filter"),
  "order"       => 130,  # YOU CAN ADJUST ORDER IN MENU HERE
  "type"        => EnumOption,
  "parameters"  => [_INTL("Off"), _INTL("On")],
  "description" => _INTL("Toggle the profanity filter."),
  "get_proc"    => proc {
    ProfanityFilter.ensure_switch_initialized
    next $game_switches[ProfanitySettings::ENABLE_PROFANITY_FILTER] ? 1 : 0
  },
  "set_proc"    => proc { |value, _scene|
    ProfanityFilter.ensure_switch_initialized
    $game_switches[ProfanitySettings::ENABLE_PROFANITY_FILTER] = (value == 1)
  }
})