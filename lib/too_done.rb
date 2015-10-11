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
    option :list, :aliases => :l, :default => "*default*", # option; what is passed on the command line or else = default 
      :desc => "The todo list which the task will be filed under."
    option :date, :aliases => :d,
      :desc => "A Due Date in YYYY-MM-DD format."     # tasks add "Mop" -l "Ryan's Chores" -d 2015-10-10
    def add(task)
      list = ToDoList.find_or_create_by(name: options[:list] , user_id:  current_user.id)
      Task.create(name: task, list_id: list.id, due_date: options[:date]) 
      #binding.pry
    end

    desc "edit", "Edit a task from a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be edited."     # tasks edit -l "Fun"
    def edit  
      list = ToDoList.find_by(user_id: current_user.id, name: options[:list]) 
        if list == nil
          puts "No list found. Does not compute."
          exit                                   # FIND FIX: When invalid or no list name passed in prompt, default tasks always shown                                  
        end                         
      tasks = Task.where(completed: false, list_id: list.id)  
        tasks.each do |task| 
          puts "Uncompleted task: #{task.name} | task-id: #{task.id}"
        end
        puts "Please choose the task id you would like to change the title for:"
        choice = STDIN.gets.chomp.to_i
        puts "What would you like the new title to be?"  # This way requires a lot of input validation... Another way with less?
        edits = STDIN.gets.chomp.to_s
        puts "If you would like to enter or modify a due date, type it in the following format: YYYY-MM-DD. If not, just hit return."
        date = STDIN.gets.chomp
        Task.update(choice, name: edits, due_date: date)
        puts "Update complete, goodbye!"
       
      # find the right todo list
      # BAIL if it doesn't exist and have tasks
      # display the tasks and prompt for which one to edit
      # allow the user to change the title, due date
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
      done = STDIN.gets.chomp.to_i               # Input validation. Blows up without correct task id..
      tasks = Task.update(done, completed: true)
      #binding.pry

      # find the right todo list
      # BAIL if it doesn't exist and have tasks
      # display the tasks and prompt for which one(s?) to mark done
    end

    desc "show", "Show the tasks on a todo list in reverse order."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be shown."
    option :completed, :aliases => :c, :default => false, :type => :boolean, # tasks show -l "Fun" -c -s 'history'
      :desc => "Whether or not to show already completed tasks."
    option :sort, :aliases => :s, :enum => ['history', 'overdue'], # two options for sort by
      :desc => "Sorting by 'history' (chronological) or 'overdue'.
      \t\t\t\t\tLimits results to those with a due date."
    def show
      list = ToDoList.find_by(user_id: current_user.id, name: options[:list]) 
        if list == nil
          puts "No list found. Does not compute."
          exit
        end

      tasks = Task.where(completed: false, list_id: list.id)
      tasks = tasks.where completed: false unless options[:completed] # This will not work wrapped in parenthesis....??
        if tasks == nil
          puts "No tasks found. Does not compute."
          exit
        end
                                                              # FIND FIX: DESC and ASC seem to be producing the same results
      tasks = tasks.order(due_date: :desc) # farthest away due_date first 
      tasks = tasks.order due_date: :asc if options[:sort] == 'history' # soonest due_date first
      tasks.each do |task|
      puts "Task name: #{task.name} | Task id: #{task.id} | Completed: #{task.completed} | Due Date: #{task.due_date}"
      end
      # find or create the right todo list
      # show the tasks ordered as requested, default to reverse order (recently entered first)
    end

    desc "delete [LIST OR USER]", "Delete a todo list or a user."
    option :list, :aliases => :l, :default => "*default*",             # tasks delete -l "Fun" -u "ryan" 
      :desc => "The todo list which will be deleted (including items)."
    option :user, :aliases => :u,
      :desc => "The user which will be deleted (including lists and items)."
    def delete
      if options[:list] && options[:user] # I have to change user to its alias here to get some stuff to work??
        puts "Does not copmute. You have to provide either the user or the list, not both."
        exit
      end

      unless options[:list] || options[:user] # I have to change user to its alias to get some stuff to work??
        puts "You must provide a user or a list. One or the other. Come on, it's not that hard!"
        exit
      end

      user = User.find_by name: options[:user] if options[:user] # Keeps processing this line even when given a list!!!! WTF  
      if user == nil
        puts "Does not compute. Could not find the user you requested."
        exit
      end
      list = ToDoList.find_by user_id: current_user.id, name: options[:list] if options[:list]
      if list == nil
        puts "Does not compute. Could not find the list you requested."
        exit
      end
      binding.pry

      # BAIL if both list and user options are provided
      # BAIL if neither list or user option is provided
      # find the matching user or list
      # BAIL if the user or list couldn't be found
      # delete them (and any dependents)
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
