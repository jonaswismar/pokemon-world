class Battle::Move

  # Records that a move was used if using the move is one of the
  # Pokemon's tasks
  def record_move_use(user, targets)
    $player.pokedex.tasks[user.species.name].each do |task|
      if task[:task] == "MOVE" && task[:move_item] == self.id.name
        $player.pokedex.increment_task_progress(task)
      end
    end

    targets.each do |target|
      return if $player.pokedex.tasks[target.species.name].nil?

      $player.pokedex.tasks[target.species.name].each do |task|
        case task[:task]
        when "DEFEATED"
          if target.fainted?
            $player.pokedex.increment_task_progress(task)
          end
        when "DEFEATEDTYPE"
          if target.fainted? && task[:move_item] == user.lastMoveUsedType.name
            $player.pokedex.increment_task_progress(task)
          end
        end
      end
    end
  end

end
