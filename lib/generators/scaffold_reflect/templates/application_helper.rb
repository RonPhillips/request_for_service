# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def default_format(instance, method)
    designator = method.split('_').last
    case 
      when designator =='on'
      fmt_date(instance.send(method))
      when designator =='at'
      fmt_time(instance.send(method))
      when designator =='usd'
      fmt_dollars(instance.send(method))
      when  [TrueClass, FalseClass].include?(instance.send(method).class)
      fmt_boolean_check(instance.send(method))
    else
      instance.send(method)
    end
  end
  
  def fmt_dollars(amt)
    amt.nil? ? 'Not entered' : sprintf("$%0.2f",amt)
  end
  
  def fmt_date(theDate, alt=nil)
    out = ''
    unless theDate.nil? or theDate == ''
      out = theDate.strftime('%m/%d/%Y')
    else
      unless alt.nil?
        out = alt
      end
    end
    out
  end
  
  def fmt_time(theDate, alt=nil)
    out = ''
    unless theDate.nil? or theDate == ''
      out = theDate.strftime('%H:%M on %m/%d/%Y')
    else
      unless alt.nil?
        out = alt
      end
    end
    out
  end
  
  def sus_color(susceptibility)
    sus_colors = {
'1' =>'#ccffff', 
'2' =>'#ccffcc',
'3' => '#ffff99',
'4' => '#ffcc99',
'5' => '#ffcccc'}
    sus_colors.default = '#ffffff'
    sus_colors[susceptibility[0..0]]
  end
  
  def nz(value, null_sub="Null")
    if value.nil? or value==''
      return null_sub
    end
    value
  end
  def fmt_boolean_check(value)
    ret = '&#9744;'
    ret = '&#9745;' if value
    ret
  end
  
end
