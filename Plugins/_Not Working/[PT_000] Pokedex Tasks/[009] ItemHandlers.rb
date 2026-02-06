# Handles what happens when an evolution stone is used
ItemHandlers::UseOnPokemon.addIf(:evolution_stones,
  proc { |item| GameData::Item.get(item).is_evolution_stone? },
  proc { |item, qty, pkmn, scene|
    if pkmn.shadowPokemon?
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    end

    newspecies = pkmn.check_evolution_on_use_item(item)
    # The evo object appears to assign pkmn = new_species, so task update
    # must be done here
    # Entire task update is executed here because if an object is passed out
    # of this function then there are some strange errors that get thrown
    $player.pokedex.tasks[pkmn.species.name].each do |task|
      if task[:task] == "EVOLVEDWITHITEM" && task[:move_item] == "FIRESTONE"
        next if task[:progress] >= GameData::Task.try_get(task[:task])&.thresholds.last

        task[:progress] += 1
      end
    end

    if newspecies
      pbFadeOutInWithMusic do
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pkmn, newspecies)
        evo.pbEvolution(false)
        evo.pbEndScreen
        if scene.is_a?(PokemonPartyScreen)
          scene.pbRefreshAnnotations(proc { |p| !p.check_evolution_on_use_item(item).nil? })
          scene.pbRefresh
        end
      end

      next true
    end
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  }
)
