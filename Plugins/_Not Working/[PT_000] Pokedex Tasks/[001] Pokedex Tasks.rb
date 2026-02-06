class PokemonPokedexInfo_Scene

  # Draw the new page in the Pokedex UI
  def drawPageTasks
    @sprites["background"].setBitmap(_INTL(Settings::POKEDEX_IMAGE_FILE_PATH))
    @sprites["formicon"].visible      = true
    overlay = @sprites["overlay"].bitmap
    arr = colour("black")
    textpos = []

    # Task banner window
    pbUpdateDummyPokemon
    @sprites["formicon"].x = 66
    @sprites["formicon"].y = 90
    pokemon = GameData::Species.try_get(@species.name)
    textpos.push([_INTL("{1}", pokemon.real_name), 100, 54, :left, arr[0], arr[1]])
    pokemon.types.each_with_index do |type, i|
      type_number = GameData::Type.get(type).icon_position
      type_rect = Rect.new(0, type_number * 32, 96, 32)
      overlay.blt(100 + (100 * i), 80, @typebitmap.bitmap, type_rect)
    end
    textpos.push([_INTL("Progress:"), 420, 54, :right, arr[0], arr[1]])
    if num_tasks_completed < 10
      arr = colour("red")
    else
      arr = colour("green")
      $player.pokedex.tasks_completed[@species.name] = true unless !$player.pokedex.tasks_completed[@species.name]
    end
    textpos.push([_INTL("{1}/10", leading_zero(num_tasks_completed)), 420, 90, :right, arr[0], arr[1]])

    # Task body window
    @range ||= [0,2]
    tasks = []
    # $player.pokedex.tasks[species_id.name] ==
    #           [{ :task => TASK_NAME, :move_item => MOVE|ITEM, :progress => 0 }]
    tasks = []
    $player.pokedex.tasks[@species.name].each_with_index do |pokemon_task, i| # Tasks by pokemon
      next unless i >= @range[0] && i <= @range[1]

      tasks << pokemon_task
    end

    arr = colour("black")
    tasks.each_with_index do |pokemon_task, i|
      task = GameData::Task.try_get(pokemon_task[:task])
      # Get move or item name if task has one associated
      # Uses try_get so tasks that do not require a move or item can return nil safely
      move_name = GameData::Move.try_get(pokemon_task[:move_item])&.name
      # move_name ||= pokemon_task[:move_item] unless pokemon_task[:move_item] == "NONE"
      move_name ||= GameData::Item.try_get(pokemon_task[:move_item])&.name
      textpos.push([_INTL("{1} {2}", task.description, move_name), 44, 143 + (77 * i), :left, arr[0], arr[1]])

       # task.thresholds == [1,2,3] as defined in PBS/task.txt for Thresholds
      task.thresholds.each_with_index do |threshold, j|
        if pokemon_task[:progress] >= threshold
          arr = colour("red")
        else
          arr = colour("black")
        end
        textpos.push([_INTL("{1}", leading_zero(threshold)), 60 + (62 * j), 183 + (77 * i), :left, arr[0], arr[1]])

        arr = colour("white")
        textpos.push([_INTL("{1}", leading_zero(pokemon_task[:progress])), 428, 183 + (77 * i), :left, arr[0], arr[1]])
      end

      arr = colour("black")
    end     
    
    pbDrawTextPositions(overlay, textpos)
  end

  def leading_zero(int)
    return "0#{int}" if int < 10

    "#{int}"
  end

  # [base_colour, shadow_colour]
  def colour(colour)
    case colour
    when "black"
      [Color.new(88, 88, 80), Color.new(168, 184, 184)]
    when "red"
      [Color.new(248, 56, 32), Color.new(224, 152, 144)]
    when "green"
      [Color.new(96, 176, 72), Color.new(174, 208, 144)]
    when "white"
      [Color.new(246, 246, 246), Color.new(168, 184, 184)]
    end
  end

  # Calculates how many tasks have been completed
  def num_tasks_completed
    num_completed = 0
    $player.pokedex.tasks[@species.name].each do |pokemon_task|
      progress = pokemon_task[:progress]
      task = GameData::Task.try_get(pokemon_task[:task])
      task.thresholds.each { |i| num_completed += 1 if progress >= i }
    end

    return num_completed
  end

  alias dewm_drawPageForms drawPageForms
  def drawPageForms
    @sprites["formicon"].x = 82
    @sprites["formicon"].y = 328
    dewm_drawPageForms
  end

  def pbScene
    Pokemon.play_cry(@species, @form)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::ACTION)
        pbSEStop
        Pokemon.play_cry(@species, @form) if @page == 1
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        ret = pbPageCustomUse(@page_id)
        if !ret
          case @page_id
          when :page_info
            pbPlayDecisionSE
            @show_battled_count = !@show_battled_count
            dorefresh = true
          when :page_forms
            if @available.length > 1
              pbPlayDecisionSE
              pbChooseForm
              dorefresh = true
            end
          end
        else
          dorefresh = true
        end
      elsif Input.repeat?(Input::UP)
        if @page == 4
          pbCursorGoToPrevious
        else
          oldindex = @index
          pbGoToPrevious
          if @index != oldindex
            pbUpdateDummyPokemon
            @available = pbGetAvailableForms
            pbSEStop
            (@page == 1) ? Pokemon.play_cry(@species, @form) : pbPlayCursorSE
            dorefresh = true
          end
        end
      elsif Input.repeat?(Input::DOWN)
        if @page == 4
          pbCursorGoToNext
        else
          oldindex = @index
          pbGoToNext
          if @index != oldindex
            pbUpdateDummyPokemon
            @available = pbGetAvailableForms
            pbSEStop
            (@page == 1) ? Pokemon.play_cry(@species, @form) : pbPlayCursorSE
            dorefresh = true
          end
        end
      elsif Input.repeat?(Input::LEFT)
        oldpage = @page
        numpages = @page_list.length
        @page -= 1
        @page = numpages if @page < 1
        @page = 1 if @page > numpages 
        if @page != oldpage
          pbPlayCursorSE
          dorefresh = true
        end
      elsif Input.repeat?(Input::RIGHT)
        oldpage = @page
        numpages = @page_list.length
        @page += 1
        @page = numpages if @page < 1
        @page = 1 if @page > numpages
        if @page != oldpage
          pbPlayCursorSE
          dorefresh = true
        end
      end
      drawPage(@page) if dorefresh
    end
    return @index
  end

  def pbCursorGoToPrevious
    new_range = @range
    arr = $player.pokedex.tasks[@species.name]
    loop do
      if new_range[0] != 0
        new_range[0] -= 3
        new_range[1] -= 3
      else
        new_range[0] = arr.length - 3
        new_range[1] = arr.length - 1
      end

      drawPage(@page)
      break
    end
  end

  def pbCursorGoToNext
    new_range = @range
    loop do
      if new_range[1] < $player.pokedex.tasks[@species.name].length - 1
        new_range[0] += 3
        new_range[1] += 3
      else
        new_range[0] = 0
        new_range[1] = 2
      end

      drawPage(@page)
      break
    end
  end

end
