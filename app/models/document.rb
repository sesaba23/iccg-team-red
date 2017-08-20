class Document < ApplicationRecord
  has_many :games
  has_many :whiteboards
end
