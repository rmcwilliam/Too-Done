#**Too Done**

Command line to-do-list using thor, activerecord and sqilite3. After forking the repo you can follow the instructions below to get started. 


To run the app from the command line:

``bundle exec ruby lib/too_done.rb``

The above should generate the following command options:

```
too_done.rb add 'TASK'             # Add a TASK to a todo list.
too_done.rb delete [LIST OR USER]  # Delete a todo list or a user.
too_done.rb done                   # Mark a task as completed.
too_done.rb edit                   # Edit a task from a todo list.
too_done.rb help [COMMAND]         # Describe available commands or one specific command
too_done.rb show                   # Show the tasks on a todo list in reverse order.
too_done.rb switch USER            # Switch session to manage USER's todo lists.
```
The following will add a task to a todo list:

```
bundle exec ruby libtoo_done.rb add "Mop" -l "Chores" -d 2015-10-10
```

Please feel free to submit a pull request regarding any code you see that needs fixing or improving. Have fun and enjoy responsibly. 
