class Battle

  # At the end of battle, calculate if the player pokemon has not fainted
  # and is holding the item associated with the task, then update the task
  alias dewmpt_pbEndOfBattle pbEndOfBattle
  def pbEndOfBattle
    dewmpt_pbEndOfBattle

    @battlers.each do |b|
      next if !b || b.item_id.nil?

      if !b.fainted? && b.pbOwnedByPlayer?
        species = GameData::Species.try_get(b.species)&.species
        $player.pokedex.tasks[species.name].each do |task|
          case task[:task]
          when "ITEMWINBATTLES"
            if task[:move_item] == b.item_id.name
              $player.pokedex.increment_task_progress(task) unless task.nil?
            end
          end
        end
      end
    end
  
    return @decision
  end

end