class Request < ApplicationRecord
  belongs_to :sync_games_manager
  belongs_to :user
  has_and_belongs_to_many :documents
end
