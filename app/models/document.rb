class Document < ApplicationRecord
  has_many :games
  has_many :whiteboards

  def get_document_type
    return self.doc_type.to_sym
  end

  def content
    return self.text
  end
  
end
