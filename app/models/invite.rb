class Invite < ApplicationRecord
  belongs_to :document
  belongs_to :sync_games_manager
  has_many :users
end
