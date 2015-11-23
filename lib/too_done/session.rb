module TooDone
  class Session < ActiveRecord::Base  
    belongs_to :user
  end
end
