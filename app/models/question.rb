class Question
  include MongoMapper::Document

  key :title,         String
  key :content,       String
  key :votes_count,   Integer, :default => 0
  key :answers_count, Integer, :default => 0
  key :views_count,   Integer, :default => 0
  key :user_id,       ObjectId
  timestamps!
  
  belongs_to :user
  many :answers
  
  def self.hot(count = 20)
    all(:limit => count, :order => "answers_count DESC")
  end
  
  def self.paginate(page = 1, limit = 20)
    all(:limit => limit, :offset => (page-1)*20, :order => "created_at DESC")
  end
  
  def self.unanswered(page = 1, limit = 20)
    t = all(:answers_count => 0, :limit => limit, :offset => (page-1)*20, :order => "created_at DESC")
    p t.size
    p t
    t
  end
  
end
