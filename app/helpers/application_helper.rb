module ApplicationHelper
  #Logo helper
  def logo
    image_tag("spottymouth.png", :alt => "Spotty Mouth")
  end
  
  #Return a title on a per-page basis
  def title
    base_title = "The Home of Burns and Insults - Spotty Mouth"
    if @title.nil?
      base_title
    else
      "#{@title}"
    end
  end
  
  def clean_name(name)
    sanitize(name, :tags => "")
  end
  
  def wrap(content)
    unless content.nil?
      content = raw(simple_format(content).split.map{ 
	  |s| wrap_long_string(s) }.join(' '))
    end
  end
  
  def name_wrap(content)
    unless content.nil?
      sanitize(content = content.split.map{ 
	  |s| wrap_long_string(s, 15) }.join(' '), :tags => "&#8203;")
    end
  end
  private
  
    def wrap_long_string(text, max_width = 80)
      zero_width_space = "&#8203;"
      regex = /.{1,#{max_width}}/
      (text.length < max_width) ? text :
	text.scan(regex).join(zero_width_space)
    end
end
