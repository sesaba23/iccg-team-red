# The purpose of this class is to record requests users make to participate in synchronous
# games. Exactly one request should exist for every queued user and no requests should exist
# for users who are not currently queued.

class Request < ApplicationRecord
  belongs_to :sync_games_manager
  belongs_to :user
  has_and_belongs_to_many :documents

  # When a user is used as a guesser, only documents that are unknown to the user
  # should be considered. This class wraps the request so that documents only
  # returns documents that are both in request.documents and unknown to
  # request.user.
  class GuesserWrapper
    def initialize (request)
      @request = request
    end

    def reader
      @request.reader
    end

    def guesser
      @request.guesser
    end

    def judge
      @request.judge
    end

    def user
      @request.user
    end
    
    def documents
      unknown_documents = @request.documents - @request.user.familiar_documents
      selected_documents = @request.documents
      return unknown_documents & selected_documents
    end
  end

  # returns: a wrapper that allows some of the same accesses, but filters
  #          documents also by whether they are known to the user.
  def as_guesser
    return GuesserWrapper.new self
  end
end
