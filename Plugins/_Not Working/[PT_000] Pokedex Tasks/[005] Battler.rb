class Battle::Battler

  # Records that a move was used during battle
  alias dewmpt_pbUseMove pbUseMove
  def pbUseMove(choice, specialUsage = false)
    move = choice[2]
    user = pbFindUser(choice, move)
    user = pbChangeUser(choice, move, user)
    targets = pbFindTargets(choice, move, user)
    targets = pbChangeTargets(move, user, targets)
    dewmpt_pbUseMove(choice, specialUsage)

    # Record use of move in pokedex
    move.record_move_use(user, targets)
  end

  alias dewmpt_pbRemoveItem pbRemoveItem
  def pbRemoveItem(permanent = true)
    $player.pokedex.tasks[self.species.name].each do |task|
      if task[:task] == "ITEMUSEBATTLE" && task[:move_item] == self.item.id.name
        $player.pokedex.increment_task_progress(task)
      end
    end

    dewmpt_pbRemoveItem(permanent)
  end

end