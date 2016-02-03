require 'yaml/store'
require_relative 'task'

class TaskManager
  attr_reader :database

  def initialize(database)
    @database = database
  end

  def create(task) # do this all atomically, transaction adds stuff via YAML
    database.transaction do
      database['tasks'] ||=[]
      database['total'] ||=0
      database['total'] += 1
      database['tasks'] << { "id" => database['total'], "title" => task[:title], "description" => task[:description]}
    end
  end

  def raw_tasks
    database.transaction do
      database['tasks'] || []
    end
  end

  def all
    raw_tasks.map { |data| Task.new(data) }
  end

  def raw_task(id)
    raw_tasks.find { |task| task["id"] == id }
  end

  def find(id)
    Task.new(raw_task(id))
  end

  def update(task, id)
    database.transaction do
      target_task = database["tasks"].find { |task| task["id"] == id.to_i }

      target_task["title"]       = task['title']
      target_task["description"] = task['description']
    end
  end

  def delete(id)
    database.transaction do
      database["tasks"].delete_if { |task| task["id"] == id.to_i }
    end
  end
end
