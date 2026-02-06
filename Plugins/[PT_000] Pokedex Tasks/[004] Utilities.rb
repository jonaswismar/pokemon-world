# Updated so that the Pokedex records when a pokemon is caught
alias dewmpt_pbAddPokemon pbAddPokemon
def pbAddPokemon(pkmn, level = 1, see_form = true)
  # pbAddPokemon returns a value, this ensures the value is
  # still returned
  bool = dewmpt_pbAddPokemon(pkmn, level, see_form)
  return if bool == false

  value = pkmn if pkmn.is_a?(String)
  value ||= pkmn.name

  task = nil
  if PBDayNight.isNight?
    $player.pokedex.tasks[value].each { |t| task = t if t[:task] == "CAPTURENIGHT" }
  elsif PBDayNight.isEvening?
    $player.pokedex.tasks[value].each { |t| task = t if t[:task] == "CAPTUREEVENING" }
  end

  if task.nil?
    $player.pokedex.tasks[value].each do |t|
      task = t if t[:task] == "CAPTURE" || t[:task] == "CAPTURE1"
    end
  end
  $player.pokedex.increment_task_progress(task) unless task.nil?

  return true
end
