# Updates the $game_temp variable to include each Pokemon and
# their tasks
class Game_Temp
  attr_accessor :tasks
end

alias dewmpt_pbClearData pbClearData
def pbClearData
  dewmpt_pbClearData
  if $game_temp
    $game_temp.tasks = nil
  end
end

# Loads and stores tasks
def pbLoadTasks
  $game_temp = Game_Temp.new if !$game_temp
  if !$game_temp.tasks
    $game_temp.tasks = load_data("Data/tasks.dat")
  end

  return $game_temp.tasks
end