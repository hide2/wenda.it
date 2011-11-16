module ApplicationHelper

  def time_ago_in_words(from_time, include_seconds = true)
    distance_of_time_in_words(from_time, Time.now, include_seconds)
  end

  def distance_of_time_in_words(from_time, to_time = 0, include_seconds = true)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round
    case distance_in_minutes
    when 0..1
      return '1 分钟前' unless include_seconds
      case distance_in_seconds
      when 0..4   then '5 秒前'
      when 5..9   then '10 秒前'
      when 10..19 then '20 秒前'
      when 20..39 then '半分钟前'
      when 40..59 then '1 分钟前'
      else '1 分钟前'
      end
    when 2..44            then "#{distance_in_minutes} 分钟前"
    when 45..89           then '1 小时前'
    when 90..1439         then "#{(distance_in_minutes.to_f / 60.0).round} 小时前"
    when 1440..2879       then '1 天前'
    when 2880..43199      then "#{(distance_in_minutes / 1440).round} 天前"
    when 43200..86399     then '1 个月前'
    when 86400..525599    then "#{(distance_in_minutes / 43200).round} 个月前"
    when 525600..1051199  then '1 年前'
    else                  "#{(distance_in_minutes / 525600).round} 年前"
    end
  end

  def years_in_words(from_time)
    to_time = Time.now
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_days = (((to_time - from_time).abs)/(60*60*24)).round
    case distance_in_days
    when 0                then "1 天"
    when 1..30            then "#{distance_in_days} 天"
    when 31..365          then "#{distance_in_days/30} 个月"
    else                       "#{distance_in_days/365} 年 #{(distance_in_days%365)/30} 个月"
    end
  end

  def s(t)
    t.strftime("%Y-%m-%d %H:%M:%S")
  end

  def ss(t)
    t.strftime("%Y-%m-%d %H:%M")
  end

  def sss(t)
    t.strftime("%Y-%m-%d")
  end

  DISALLOWED_TAGS = %w(script iframe) unless defined?(DISALLOWED_TAGS)

  def blacklist(html)
    # only do this if absolutely necessary
    if html.index("<")
      tokenizer = HTML::Tokenizer.new(html)
      new_text = ""

      while token = tokenizer.next
        node = HTML::Node.parse(nil, 0, 0, token, false)
        new_text << case node
                    when HTML::Tag
                      if DISALLOWED_TAGS.include?(node.name)
                        node.to_s.gsub(/</, "&LT;")
                      else
                        node.to_s
                      end
                    else
                      node.to_s.gsub(/</, "&LT;")
                    end
      end

      html = new_text
    end
    html
  end

  def show_ip_address(ip)
    IP_LIB.find(ip).country.to_s
  end

end
