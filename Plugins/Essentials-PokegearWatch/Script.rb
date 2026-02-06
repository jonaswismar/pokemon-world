#===============================================================================
# * Watch in the Pokegear Menu - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It adds a watch in the Pokégear menu.
#
#== INSTALLATION ===============================================================
#
# To this script works, put it above main OR convert into a plugin.  Put an 
# image in "Graphics/Pictures/Pokegear/watch". At UI_Pokegear script section, 
# before line 'pbFadeInAndShow(@sprites) { pbUpdate }' add line
# 'initialize_watch'.
#
# At older versions, the section is called PScreen_Pokegear and the line in
# this script is 'Graphics.transition'.
#
#== NOTES ======================================================================
#
# You can change date format making the time_format method returns a fixed
# format. Example: Making it returns "%I:%M:%S %p | %a" put abbreviated weekday
# name.
#
#===============================================================================

if defined?(PluginManager) && !PluginManager.installed?("Pokegear Watch")
  PluginManager.register({                                                 
    :name    => "Pokegear Watch",                                        
    :version => "1.2",                                                     
    :link    => "https://www.pokecommunity.com/showthread.php?t=323464",             
    :credits => "FL"
  })
end

# To support older versions
PokemonPokegear_Scene = Scene_Pokegear if !defined?(PokemonPokegear_Scene) 

class PokemonPokegear_Scene
  USE_PM_AM = true # Make it false to use European format
  SHOW_SECONDS = true # Make it false to won't show the seconds
  SHOW_WEEKDAY_NAME = true # Make it false to won't show weekday name

  if method_defined?(:update) # to support on older versions
    alias :_old_fl_watch_update :update
    def update
      refresh_date
      _old_fl_watch_update
    end
  else
    alias :_old_fl_watch_update :pbUpdate
    def pbUpdate
      refresh_date
      _old_fl_watch_update
    end
  end
  
  def initialize_watch
    @sprites["watch"] = IconSprite.new(0,0,@viewport)
    @sprites["watch"].setBitmap("Graphics/Pictures/Pokegear/watch")
    @sprites["watch"].x = (Graphics.width - @sprites["watch"].bitmap.width)/2
    @sprites["overlay"] = BitmapSprite.new(
      Graphics.width,Graphics.height,@viewport
    )
    pbSetSystemFont(@sprites["overlay"].bitmap)
    refresh_date
  end
  
  def refresh_date
    new_date = pbGetTimeNow.strftime(time_format)
    return false if @date_string == new_date
    @date_string = new_date  
    @sprites["overlay"].bitmap.clear
    PokegearWatchBridge.drawTextPositions(@sprites["overlay"].bitmap, [[
      @date_string,Graphics.width/2,4,2,
      Color.new(72,72,72),Color.new(160,160,160)
    ]])
    return true
  end

  def time_format
    ret = "%M"
    ret +=":%S" if SHOW_SECONDS
    ret = USE_PM_AM ? "%I:#{ret} %p" : "%H:#{ret}"
    ret = "%A "+ret if SHOW_WEEKDAY_NAME
    return ret
  end
end

# Essentials multiversion layer
module PokegearWatchBridge
  if defined?(Essentials)
    MAJOR_VERSION = Essentials::VERSION.split(".")[0].to_i
  else
    MAJOR_VERSION = 0
  end

  module_function

  def drawTextPositions(bitmap,textpos)
    if MAJOR_VERSION < 20
      for singleTextPos in textpos
        singleTextPos[2] -= MAJOR_VERSION==19 ? 12 : 6
      end
    end
    return pbDrawTextPositions(bitmap,textpos)
  end
end