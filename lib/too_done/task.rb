module TooDone
  class Task < ActiveRecord::Base
    belongs_to :to_do_list
  end
end