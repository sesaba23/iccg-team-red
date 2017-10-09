class User < ApplicationRecord

  serialize :known_documents, Array # an array of document ids. Each document id occurs at most once.
  belongs_to :invite
  has_one :request
  
    attr_accessor :remember_token
    before_save { self.email = email.downcase }
    validates :name, presence: true, length: {maximum: 50}
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: {maximum: 255},
                format: {with: VALID_EMAIL_REGEX},
                uniqueness: {case_sensitive: false}

    # The only requirement for has_secure_password to work its magic is
    # for the corresponding model to have an attribute called password_digest
    has_secure_password
    validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

    # Returns the hash digest of the given string.
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    # Returns a random token.
    def User.new_token
        SecureRandom.urlsafe_base64
    end

    # Remembers a user in the database for use in persistent sessions.
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end

    # Returns true if the given token matches the digest.
    def authenticated?(remember_token)
        return false if remember_digest.nil?
        BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end

    # Forgets a user.
    def forget
        update_attribute(:remember_digest, nil)
    end

    # adds a document to this user's known documents
    # param document: a document instance
    def knows (document)
      self.known_documents << document.id unless self.known_documents.include? document.id
      self.save
    end

    # get this user's known documents
    # returns: an array of documents this user already knows
    def familiar_documents
      self.known_documents.map {|doc_id| Document.find_by(id: doc_id)}
    end

    # determine if this user is familiar with a document
    # param document: a document instance
    # returns: a boolean indicating whether the user is familiar with this document
    def knows? (document)
      self.known_documents.include? document.id
    end
end
