module Compiler
  module_function

  def compile_pbs_files
    text_files = get_all_pbs_files_to_compile
    modify_pbs_file_contents_before_compiling
    compile_town_map(*text_files[:TownMap][1])
    compile_connections(*text_files[:Connection][1])
    compile_types(*text_files[:Type][1])
    compile_abilities(*text_files[:Ability][1])
    compile_moves(*text_files[:Move][1])                       # Depends on Type
    compile_items(*text_files[:Item][1])                       # Depends on Move
    compile_berry_plants(*text_files[:BerryPlant][1])          # Depends on Item
    compile_pokemon(*text_files[:Species][1])                  # Depends on Move, Item, Type, Ability
    compile_pokemon_forms(*text_files[:Species1][1])           # Depends on Species, Move, Item, Type, Ability
    compile_pokemon_metrics(*text_files[:SpeciesMetrics][1])   # Depends on Species
    compile_shadow_pokemon(*text_files[:ShadowPokemon][1])     # Depends on Species
    compile_regional_dexes(*text_files[:RegionalDex][1])       # Depends on Species
    compile_ribbons(*text_files[:Ribbon][1])
    compile_encounters(*text_files[:Encounter][1])             # Depends on Species
    compile_trainer_types(*text_files[:TrainerType][1])
    compile_trainers(*text_files[:Trainer][1])                 # Depends on Species, Item, Move
    compile_trainer_lists                                      # Depends on TrainerType
    compile_metadata(*text_files[:Metadata][1])                # Depends on TrainerType
    compile_map_metadata(*text_files[:MapMetadata][1])
    compile_dungeon_tilesets(*text_files[:DungeonTileset][1])
    compile_dungeon_parameters(*text_files[:DungeonParameters][1])
    compile_phone(*text_files[:PhoneMessage][1])               # Depends on TrainerType

    # New
    compile_tasks(*text_files[:Task][1])
    compile_pokemon_tasks
  end

  # Compile PBS/tasks.txt into:
  #   {TASK=>{SourceName=>String, Name=>String, Decsription=>String, Index=>int, Threshold=>[int,int..]}}
  def compile_tasks(*paths)
    compile_PBS_file_generic(GameData::Task, *paths) do |final_validate, hash|
      (final_validate) ? validate_all_compiled_tasks : validate_compiled_task(hash)
    end
  end

  def validate_compiled_task(hash)
  end

  def validate_all_compiled_tasks
  end

  # Compile PBS/pokemon_tasks.txt into:
  #   {POKEMON=>[[TASK1,MOVE|ITEM],[TASK2,MOVE|ITEM]]}
  # 'MOVE|ITEM' is nil if the task does not require use of a move or an item
  def compile_pokemon_tasks
    # Recreates the file, giving each Pokemon their respective CAPTURE task, used when
    # new Pokemon need to be added. IMPORTANT make sure you backup your file before
    # uncommenting this code. It WILL overwrite all tasks except for the CAPTURE task
    # File.open(Settings::PBS_POKEMON_TASKS_PATH + ".txt", "w") do |f|
    #   f.write("[0]\n")
    #   GameData::Species.each_species do |s|
    #     if s.flags.include?("Legendary") || s.flags.include?("Mythical")
    #       f.write("#{s.id},CAPTURE1,NONE\n")
    #     else
    #       f.write("#{s.id},CAPTURE,NONE\n")
    #     end
    #   end
    # end

    sections = {}
    compile_pbs_file_message_start(Settings::PBS_POKEMON_TASKS_PATH + ".txt")
    section = nil
    pbCompilerEachPreppedLine(Settings::PBS_POKEMON_TASKS_PATH + ".txt") do |line, line_no|
      if line[/^\s*\[\s*(\d+)\s*\]\s*$/] # e.g. [0]
        section = $~[1].to_i
        sections[section] = {}
      else
        raise _INTL("Expected a section at the beginning of the file.") + "\n" + FileLineData.linereport if !section

        values = line.split(",")
        name = values.first
        values = values.drop(1) # Remove name from array as it will become {name => values}
        key = nil

        # Because a task can have a move or item associated with it, every second value is
        # the name of the move or item, e.g. MOVE,GROWL,ITEM,POTION,CAPTURE,NONE if a task
        # does not have anything associated with it e.g. CAPTURE, then the value is NONE
        values = values.map.with_index do |val, i|
          if i % 2 != 0
            {key => val}
          else
            key = val
            next
          end
        end.compact # Removes nil objects from NONE values
        sections[section][name] = values
      end
    end
    process_pbs_file_message_end

    # Creates and/or saves to Data/tasks.dat
    save_data(sections[section], "Data/tasks.dat")
  end
end
