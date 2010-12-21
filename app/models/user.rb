class User
  include MongoMapper::Document

  key :name,  String, :required => true
  key :email, String, :required => true
  
  many :questions
  many :answers
  many :badges
end
