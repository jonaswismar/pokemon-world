module PartyPicture
  
  FILTERS = [
  ["Pink", Tone.new(80, 10, 75, 0)],
  ["Sepia", Tone.new(0, 0, -85, 100)],
  ["B&W", Tone.new(-20, -20, -20, 255)],
  ["Bright", Tone.new(60, 60, 60, 0)],
  ["Dark", Tone.new(-60, -60, -60, 40)]
  ]
  
  OVERLAYS = [
  ["Pretty Pink", "Pretty Pink Overlay"],
  ["Pretty Blue", "Pretty Blue Overlay"],
  ["Sparkles", "Sparkles Overlay"],
  ["Polaroid", "Polaroid Overlay"],
  ["Vignette", "Vignette Overlay"]
  ]
  
  MAX_HORIZONTAL_MOVEMENT = 2
  MAX_VERTICAL_MOVEMENT = 2
  
  DIRECTORY = "Screenshots/"
  
  def self.start(ev1, ev2, ev3, ev4, ev5, ev6, keep_npc = false)
    snap_edges = GameData::MapMetadata.try_get($game_map.map_id).snap_edges
    initSprites
    ids = initScene(ev1, ev2, ev3, ev4, ev5, ev6, keep_npc)
    main(ids, snap_edges)
  end
  
  def self.main(ids, snap_edges)
    current_x = 0
    current_y = 0
    took_picture = false
    
    loop do
      pbUpdateSceneMap
      Graphics.update
      Input.update
      if Input.press?(Input::UP) && !snap_edges
        if current_y == MAX_VERTICAL_MOVEMENT
          pbSEPlay("Player bump")
          pbWait(0.25)
        else
          pbScrollMap(8,1)
          current_y += 1
        end
      elsif Input.press?(Input::DOWN) && !snap_edges
        if current_y == -MAX_VERTICAL_MOVEMENT
          pbSEPlay("Player bump")
          pbWait(0.25)
        else
          pbScrollMap(2,1)
          current_y -= 1
        end
      elsif Input.press?(Input::LEFT) && !snap_edges
        if current_x == -MAX_HORIZONTAL_MOVEMENT
          pbSEPlay("Player bump")
          pbWait(0.25)
        else
          pbScrollMap(4,1)
          current_x -= 1
        end
      elsif Input.press?(Input::RIGHT) && !snap_edges
        if current_x == MAX_HORIZONTAL_MOVEMENT
          pbSEPlay("Player bump")
          pbWait(0.25)
        else
          pbScrollMap(6,1)
          current_x += 1
        end
      elsif Input.trigger?(Input::ACTION)
        choice = pbMessage("Do you want to take a picture?", [
          _INTL("Yes"),
          _INTL("No")
        ])
        
        if choice == 0
          took_picture = takePicture
          endScene(ids)
          return true
        end
      elsif Input.trigger?(Input::USE)
        choice = pbMessage("You wanna use some filters or overlays?", [
          _INTL("Filters"),
          _INTL("Overlays"),
          _INTL("Nah")
        ])
        if choice == 0
          filters_names   = FILTERS.map { |filter| filter[0] }
          filter_choice = pbMessage("Which filter do you want?",
            filters_names + [_INTL("Normal"), _INTL("Nevermind")
          ])
          filters_effects = FILTERS.map { |filter| filter[1] }
          if filter_choice != FILTERS.size + 1
            if filter_choice != FILTERS.size
              pbToneChangeAll(filters_effects[filter_choice], 4)
            else
              pbToneChangeAll(Tone.new(0, 0, 0, 0), 4)
            end
          end
        elsif choice == 1
          overlays_names = OVERLAYS.map { |overlay| overlay[0] }
          overlay_choice = pbMessage("Which overlay do you want?", 
          overlays_names + [_INTL("None"), _INTL("Nevermind")
          ])
          overlays_images = OVERLAYS.map { |overlay| overlay[1] }
          if overlay_choice != OVERLAYS.size + 1
            if overlay_choice != OVERLAYS.size
              @sprites["filter_overlay"].bitmap = Bitmap.new("Graphics/Party Picture/" + overlays_images[overlay_choice])
              @sprites["filter_overlay"].visible = true
            else
              @sprites["filter_overlay"].visible = false
            end
            pbSEPlay("GUI naming tab swap start")
          end        
        end
      elsif Input.trigger?(Input::BACK)
        choice = pbMessage("You want to give up?", [
          _INTL("Yes"),
          _INTL("No")
        ])
        if choice == 0
          pbMessage("Ok!")
          endScene(ids)
          took_picture = true
          return false
        end
      end
      break if took_picture
    end
  end
  
  def self.initScene(ev1, ev2, ev3, ev4, ev5, ev6, keep_npc)
    pbFadeOutIn do
      if !keep_npc
        $game_map.events.each do |event_id, event|
          event.transparent = true
        end
      end
      ids = []
      evs = [ev1, ev2, ev3, ev4, ev5, ev6]
      party = $player.party
      party.each_with_index do |pkmn, i|
        next if pkmn.fainted?
        shiny = pkmn.shiny?
        file = GameData::Species.ow_sprite_filename(pkmn.species, pkmn.form, pkmn.gender, shiny, pkmn.shadow)
        file.gsub!("Graphics/Characters/", "")
        ids[i] = Rf.create_event { |event|
          event.x = evs[i][0]
          event.y = evs[i][1]
          event.pages[0].step_anime = true
          event.pages[0].graphic.character_name = file
        }
      end

      FollowingPkmn.toggle_off      
      $game_player.direction = 2
      @sprites["overlay"].visible = true
      $game_map.need_refresh = true
      pbWait(0.5)
      $scene.miniupdate
      pbWait(0.5)
      
      return ids
    end
  end
  
  def self.initSprites
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @sprites = {}
    @sprites["filter_overlay"] = Sprite.new(@viewport)
    @sprites["filter_overlay"].visible = false
    @sprites["filter_overlay"].bitmap = Bitmap.new("Graphics/Party Picture/Polaroid Overlay")
    @sprites["overlay"] = Sprite.new(@viewport)
    @sprites["overlay"].visible = false
    @sprites["overlay"].bitmap = Bitmap.new("Graphics/Party Picture/Camera Overlay.png")
  end
  
  def self.endScene(ids)
    pbScrollMapToPlayer(4)
    pbFadeOutIn do
      $game_map.events.each do |event_id, event|
        event.transparent = false
      end
      party = $player.party
      party.each_with_index do |pkmn, i|
        next if pkmn.fainted?
        Rf.delete_event(ids[i])
      end
      FollowingPkmn.toggle_on
      pbToneChangeAll(Tone.new(0, 0, 0, 0), 4)
      pbDisposeSpriteHash(@sprites)
      @viewport.dispose
      $game_map.need_refresh = true
      pbWait(0.5)
      $scene.miniupdate
    end
  end
  
  def self.takePicture
    @sprites["overlay"].visible = false
    pbSEPlay("Battle catch click")
    pbFlash(Color.new(255, 255, 255, 255), 10)
    pbWait(11.0/20)
    
    map_name = $game_map.name
    exporter_filename = "#{map_name}_Picture.png"
    create_folder_if_not_exist(DIRECTORY)
    counter = 0
    while File.exist?(DIRECTORY + exporter_filename)
      counter += 1
      exporter_filename = "#{map_name}_Picture(#{counter}).png"
    end
    bmp = Graphics.snap_to_bitmap
    bmp.save_to_png(DIRECTORY + exporter_filename)
    bmp.dispose
    @sprites["overlay"].visible = true
    pbWait(6.0/20)
    return true
  end
  
  def self.create_folder_if_not_exist(folder_path)
    unless Dir.exist?(folder_path)
      # Create the folder if it doesn't exist
      Dir.mkdir(folder_path)
    end
  end
  
  def self.pbUpdateSceneMap
    $scene.miniupdate if $scene.is_a?(Scene_Map) && !pbIsFaded?
  end
end