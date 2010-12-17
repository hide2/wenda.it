require File.dirname(__FILE__)+'/config/environment'

Question.all.each do |q|
  q.destroy
end

(1..20).each do |t|
  q = Question.new
  q.title = t.to_s + ". 测试<script>alert(123);</script>"
  q.content = "如题如题如题如题如题如题如题如题<script>alert(123);</script>"
  q.save
  p q
  p "---------------------------------------------------"
end