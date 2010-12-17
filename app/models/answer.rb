class Answer
  include MongoMapper::Document

  key :content,     String
  key :votes_count, Integer, :default => 0
  key :user_id,     ObjectId
  key :question_id, ObjectId
  
  belongs_to :user
  belongs_to :questions
end
