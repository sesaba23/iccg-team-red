class Whiteboard < ApplicationRecord
  belongs_to :game
  belongs_to :document
end
