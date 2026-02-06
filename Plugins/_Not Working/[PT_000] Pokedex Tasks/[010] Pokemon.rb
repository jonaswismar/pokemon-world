class Pokemon

  # Checks to see if the evolving Pokemon has the EVOLVED task and
  # if so then updates the task progress 
  alias dewmpt_action_after_evolution action_after_evolution
  def action_after_evolution(new_species)
    $player.pokedex.tasks[species.name].each do |task|
      if task[:task] == "EVOLVED"
        $player.pokedex.increment_task_progress(task) unless task.nil?
      end
    end

    dewmpt_action_after_evolution(new_species)

    $player.pokedex.set_seen(new_species)
    task = nil
    if PBDayNight.isNight?
      $player.pokedex.tasks[new_species.name].each { |t| task = t if t[:task] == "CAPTURENIGHT" }
    elsif PBDayNight.isEvening?
      $player.pokedex.tasks[new_species.name].each { |t| task = t if t[:task] == "CAPTUREEVENING" }
    end

    if task.nil?
      $player.pokedex.tasks[new_species.name].each do |t|
        task = t if t[:task] == "CAPTURE" || t[:task] == "CAPTURE1"
      end
    end
    $player.pokedex.increment_task_progress(task) unless task.nil?
  end

end