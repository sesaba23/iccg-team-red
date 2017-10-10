class Invite < ApplicationRecord
  belongs_to :document
  belongs_to :sync_games_manager
  has_many :users
  serialize :accepted, Array

  def accept user
    raise StandardError unless self.users.include? user
    self.accepted << user unless self.accepted.include? user
    self.save
  end

  def all_accepted?
    self.accepted.size == 3
  end
end
