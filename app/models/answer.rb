class Answer
  include MongoMapper::Document

  key :content,     String
  key :votes_count, Integer, :default => 0
  key :user_id,     ObjectId
  key :question_id, ObjectId
  key :votes,           Array # user_id array
  # tags in ruby: ["4d1033f698d1b102cb00000a", "4d1033f698d1b102cb00000b", "4d1033f698d1b102cb00000c"]
  # tags in bson: ["4d1033f698d1b102cb00000a", "4d1033f698d1b102cb00000b", "4d1033f698d1b102cb00000c"]
  timestamps!

  belongs_to :user
  belongs_to :question
  many :comments
end
