class User
  include MongoMapper::Document

  key :name,  String
  key :email, String
  
  many :questions
  many :answers
end
