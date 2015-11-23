require "too_done/version"
require "too_done/init_db"
require "too_done/user"
require "too_done/session"

require "too_done/to_do_list"
require "too_done/task"

require "thor"
require "pry"

module TooDone
  class App < Thor

    desc "add 'TASK'", "Add a TASK to a todo list."  
    option :list, :aliases => :l, :default => "*default*", 
      :desc => "The todo list which the task will be filed under."
    option :date, :aliases => :d,
      :desc => "A Due Date in YYYY-MM-DD format."     # tasks add "Mop" -l "Ryan's Chores" -d 2015-10-10
    def add(task)
      list = ToDoList.find_or_create_by(name: options[:list] , user_id:  current_user.id)
      Task.create(name: task, list_id: list.id, due_date: options[:date]) 
    end


    desc "edit", "Edit a task from a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be edited."     # tasks edit -l "Fun"
    def edit  
      list = ToDoList.find_by(user_id: current_user.id, name: options[:list]) 
        if list == nil
          puts "No list found. Does not compute."
          exit                                                                     
        end                         
      tasks = Task.where(list_id: list.id, completed: false)  
        tasks.each do |task| 
          puts "Uncompleted task: #{task.name} | task-id: #{task.id}"
        end
        puts "Please choose the task id you would like to edit:"
        task_id = STDIN.gets.chomp.to_i
        puts "What would you like the new title to be? Leave blank and hit if no change is required"  
        new_title = STDIN.gets.chomp.to_s
        puts "If you would like to enter or modify a due date, type it in the following format: YYYY-MM-DD. Leave blank and hit return if no change is required."
        new_due_date = STDIN.gets.chomp

        edit_task = Task.find(task_id)
        edit_task.name = new_title unless new_title.empty?
        edit_task.new_due_date = new_due_date unless new_due_date.empty?
        edit_task.update
        puts "Update complete, goodbye!"
    end
  
    desc "done", "Mark a task as completed."
    option :list, :aliases => :l, :default => "*default*",  # tasks show -l "Ryan's Chores"
      :desc => "The todo list whose tasks will be completed."
    def done
    list = ToDoList.find_by(user_id: current_user.id, name: options[:list])
      if list == nil 
        puts "No list found. Does not compute."                     
        exit
      end

      tasks = Task.where(completed: false, list_id: list.id)
        tasks.each do |task|
          puts "Task Name: #{task.name} | Task id: #{task.id} | Task Completed: #{task.completed}"
        end
      puts "Please choose the task id you would like to mark as completed:" 
      done = STDIN.gets.chomp.to_i               
      tasks = Task.update(done, completed: true)
    end

    desc "show", "Show the tasks on a todo list in reverse order."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be shown."
    option :completed, :aliases => :c, :default => false, :type => :boolean, # tasks show -l "Fun" -c -s 'history'
      :desc => "Whether or not to show already completed tasks."
    option :sort, :aliases => :s, :enum => ['history', 'overdue'], 
      :desc => "Sorting by 'history' (chronological) or 'overdue'.
      \t\t\t\t\tLimits results to those with a due date."
    def show
      list = ToDoList.find_by(user_id: current_user.id, name: options[:list]) 
        if list == nil
          puts "No list found. Does not compute."
          exit
        end

      tasks = Task.where(completed: false, list_id: list.id)
      tasks = tasks.where(completed: false) unless options[:completed] 
        if tasks == nil
          puts "No tasks found. Does not compute."
          exit
        end
                                                      
      tasks = tasks.order(due_date: :desc) 
      tasks = tasks.order due_date: :asc if options[:sort] == 'history' 
      tasks.each do |task|
        puts "Task name: #{task.name} | Task id: #{task.id} | Completed: #{task.completed} | Due Date: #{task.due_date}"
      end
    end

    desc "delete [LIST OR USER]", "Delete a todo list or a user."
    option :list, :aliases => :l,             # tasks delete -l "Fun" -u "ryan" 
      :desc => "The todo list which will be deleted (including items)."
    option :user, :aliases => :u,
      :desc => "The user which will be deleted (including lists and items)."
    def delete
      if options[:list] && options[:user] 
        puts "Does not compute. You have to provide either the user or the list, not both."
        exit
      end

      if options[:list].nil? && options[:user].nil? 
        puts "You must provide a user or a list. One or the other. Come on, it's not that hard!"
        exit
      end

      if options[:user] && options[:list].nil?
        user = User.find_by name: options[:user] 
        if user.nil?
          puts "Does not compute. Could not find the user you requested."
          exit
        end
        user.destroy
      elsif options[:list] && options[:user].nil?
        list = ToDoList.find_by user_id: current_user.id, name: options[:list]
        if list.nil? 
          puts "Does not compute. Could not find the list you requested."
          exit
        end
        list.destroy
      end  
    end

    desc "switch USER", "Switch session to manage USER's todo lists." # tasks switch(ryan)
    def switch(username)
      user = User.find_or_create_by(name: username)
      user.sessions.create
    end

    private
    def current_user 
      Session.last.user
    end
  end
end


TooDone::App.start(ARGV)
