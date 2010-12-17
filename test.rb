require File.dirname(__FILE__)+'/config/environment'

q = Question.new
q.title = "测试中文，呵呵asdfqw&（*￥&（#￥*'''@￥@#（asdfadslf<script>alert(123);</script>!!!"
q.content = "如题如题如题如题如题如题如题如题asdfqw&（*￥&（'''#￥*@￥@#（asdfadslf<script>alert(123);</script>!!!"
q.save