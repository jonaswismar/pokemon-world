class Player < Trainer
  class Pokedex

    alias dewmpt_clear clear
    def clear
      @tasks = {} # Clear task data in Pokedex
      @tasks_completed = {}
      dewmpt_clear
    end

    # Called when a Pokemon is seen
    alias dewmpt_set_seen set_seen
    def set_seen(species, should_refresh_dexes = true)
      dewmpt_set_seen(species, should_refresh_dexes)

      # Add all pokemon tasks to pokedex's tasks
      species_id = GameData::Species.try_get(species)&.species

      if @tasks[species_id.name].nil?
        # Create record if one does not exist
        @tasks[species_id.name] = [] # if @tasks[species_id.name].nil?
        # Initialize all tasks to 0
        pbLoadTasks[species_id.name].each do |task|
          # @tasks[species_id.name] == [{ :task => TASK_NAME, :move_item => MOVE|ITEM, :progress => 0 }]
          # e.g @tasks["EEVEE"] == [{ :task => "CAPTURE", :move_item => NONE, :progress => 5 }]
          hash = {
            :task      => task.keys.first,
            :move_item => task[task.keys.first],
            :progress  => 0
          }
          @tasks[species_id.name].push(hash) unless @tasks[species_id.name].include?(hash)
        end

        @tasks_completed[species_id.name] = false
      end
    end

    # Increment task progress
    def increment_task_progress(task)
      return if task[:progress] >= GameData::Task.try_get(task[:task])&.thresholds.last

      task[:progress] += 1
    end

    # Returns all stored tasks, used by Pokedex UI
    def tasks
      @tasks
    end

    def tasks_completed
      @tasks_completed
    end

  end
end
