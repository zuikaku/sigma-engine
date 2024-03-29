# -*- coding: utf-8 -*-

module ApplicationHelper
  def verbose_date date
    months = [  'января',   'февраля',    'марта',
                'апреля',   'мая',        'июня',
                'июля',     'августа',    'сентября',
                'октября',  'ноября',     'декабря'    ]
    now = Time.now.getlocal
    date = date.getlocal  
    if now.day == date.day
      if [now.month, now.year] == [date.month, date.year]
        result = 'сегодня '
      end
    elsif date.day == (now.day - 1)
      if [now.month, now.year] == [date.month, date.year]
        result = 'вчера '
      end
    else
      month = months[date.month - 1]
      result = "#{date.day} #{month} #{date.year} "
    end
    return result + 'в ' + date.strftime('%H.%M')
  end

  def verbose_replies number, type='default'
    if type == 'new'
      result = number.to_s + ' сообщени'
      number_mod = number % 10
      if number_mod == 1 and number != 11
        return result += 'й'
      else
        return result += 'х'
      end
    else
      result = 'сообщени'
      number_mod = number % 10
      if (2..4).include? number_mod and not (12..14).include? number
        return result + 'я'
      elsif number_mod != 1 or number == 11
        return result + 'й'    
      else
        return result + 'е'
      end
    end
  end
end
