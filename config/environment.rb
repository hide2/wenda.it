# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
WendaIt::Application.initialize!

# limit par page
LIMIT = 10

# user avatar upload path
AVATAR_PATH = "/upload/images/avatar/"

# find ip address
IP_LIB = QQWry::QQWryFile.new

# default title/meta/keyword
SITE_NAME = "wenda.it"
DEFAULT_TITLE = "wenda.it - 做国内最好的IT专业知识问答网站"
DEFAULT_META = "wenda.it,Java,Spring,Hibernate,Struts,Eclipse,AJAX,Ruby,Ruby on rails,Python,Django,jQuery,json,JavaScript,Android,iphone,mac os,objective-c,cocoa,html,html5,css,Flex,Flash,C#,.net,C,C++,Erlang,PHP,ubuntu,Linux,Agile,Scrum,XP,TDD,SQL,MySQL,Oracle,NOSQL,mongodb,svn,git"
DEFAULT_KEYWORDS = "wenda.it Java AJAX Ruby Ruby on rails Linux Agile Scrum MySQL NOSQL mongodb"

# Douban/Sina API
DOUBAN_API_KEY = "0ba792a10764637022f6b7e3162d2a50"
DOUBAN_API_KEY_SECRET = "05d3281b7f194008"
SINA_API_KEY = "3246097489"
SINA_API_KEY_SECRET = "61b8d9bf1a747f18b65f357ec64769f3"