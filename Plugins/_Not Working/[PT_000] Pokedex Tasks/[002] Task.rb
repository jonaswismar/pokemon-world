# Individual Task object, can be accessed via
#   GameData::Task.get(TASK_SOURCE_NAME) | .try_get(TASK_SOURCE_NAME)
# This is not associated with any pokemon, it is merely an object the
# name, description and thresholds are stored. Pokemon and their tasks
# are stored in the $player.pokedex object
module GameData
  class Task

    attr_reader :source_name
    attr_reader :name
    attr_reader :description
    attr_reader :thresholds
    attr_reader :pbs_file_sufffix

    DATA = {}
    DATA_FILENAME = Settings::DAT_TASK_FILE_PATH
    PBS_BASE_FILENAME = Settings::PBS_TASK_FILE_PATH

    extend ClassMethodsSymbols
    include InstanceMethods

    # Allows Compiler to create all task objects from PBS/task.txt
    SCHEMA = {
      "SourceName"  => [:source_name, "n"],
      "Name"        => [:name,        "s"],
      "Description" => [:description, "s"],
      "Thresholds"  => [:thresholds,  "*u"]
    }

    def initialize(hash)
      @source_name      = hash[:source_name]
      @name             = hash[:name]            || "Unnamed"
      @description      = hash[:description]     || "nil"
      @thresholds       = hash[:thresholds]      || []
      @pbs_file_suffix  = hash[:pbs_file_suffix] || ""
    end

    def source_name
      @source_name
    end

    def name
      @name
    end

    def description
      @description
    end

    def thresholds
      @thresholds
    end

  end
end
