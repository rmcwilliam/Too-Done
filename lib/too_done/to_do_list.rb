module TooDone
  class ToDoList < ActiveRecord::Base
    has_many :tasks
    belongs_to :user
  end
end