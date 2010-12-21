class Question
  include MongoMapper::Document

  key :title,         String,  :required => true
  key :content,       String,  :required => true
  key :votes_count,   Integer, :default => 0
  key :answers_count, Integer, :default => 0
  key :views_count,   Integer, :default => 0
  key :user_id,       ObjectId
  key :tags,          Array
  # tags in ruby: [{"id" => "4d1033f698d1b102cb00000a", "name" => "ruby"}, {"id" => "4d1033f698d1b102cb00000b", "name" =>"rails"}]
  # tags in bson: [{"id" : "4d1033f698d1b102cb00000a", "name" : "ruby"}, {"id" => "4d1033f698d1b102cb00000b", "name" : "rails"}]
  timestamps!
  
  belongs_to :user
  many :answers
  
  def self.hot(count = 20)
    all(:limit => count, :order => "answers_count DESC, views_count DESC, created_at DESC")
  end
  
  def self.paginate(page = 1, limit = 20)
    all(:limit => limit, :offset => (page-1)*20, :order => "created_at DESC")
  end
  
  def self.unanswered(page = 1, limit = 20)
    t = all(:answers_count => 0, :limit => limit, :offset => (page-1)*20, :order => "created_at DESC")
    t
  end
  
  def has_tag(t)
    self.tags.each do |tag|
      return true if tag["name"] == t.name
    end
    return false
  end
  
  def save_tags(tags)
    tags_array = []
    tags.split(" ").each do |tag|
      t = Tag.find_by_name(tag)
      if t
        t.questions_count += 1 if !self.has_tag(t)
      else
        t = Tag.new
        t.name = tag
      end
      t.save
      tags_array << t
    end
    self.tags = tags_array.map{|t|{"id" => t.id.to_s, "name" => t.name}}
  end
  
end
