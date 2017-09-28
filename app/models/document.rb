class Document < ApplicationRecord
  has_many :games
  has_many :whiteboards

  def get_document_type
    return self.kind.to_sym
  end
end
