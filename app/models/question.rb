class Question
  include MongoMapper::Document

  key :title,   String
  key :content, String
  key :user_id, ObjectId
  timestamps!
  
  belongs_to :user
  many :answers
  
  def self.latest(count=20)
    all(:limit => count, :order => "created_at DESC") 
  end 
end
