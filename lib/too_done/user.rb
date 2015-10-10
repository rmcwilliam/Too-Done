module TooDone
  class User < ActiveRecord::Base
    has_many :sessions
    has_many :to_do_lists
  end
end
