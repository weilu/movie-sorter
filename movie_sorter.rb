require 'cgi'
require 'open-uri'
require 'nokogiri'

host = "http://www.imdb.com"
now = Time.now.strftime("%Y%m%d%I%M%p")
f = File.open("process_#{now}.log", 'a')

Dir.foreach("/Volumes/FREECOM\ HDD/MOVIES-EBERT/") do |file|
  begin
    next if file.to_s =~ /^\./
    raw_title = file.to_s.gsub(/\.\w+$/, '')

    url = "#{host}/find?q=#{CGI.escape(raw_title)}"
    f.write "Searching for #{raw_title}\n"

    page = Nokogiri::HTML(open url)
    first_link = page.css("a[href^='/title']")[0]
    next if first_link.nil? || first_link['href'][/\d*\/$/].nil?

    link = first_link['href']
    title = first_link.content
    f.write "movie #{title} found at: #{link}\n"

    movie_page = Nokogiri::HTML(open host+link)
    star = movie_page.css('.star-box-giga-star')[0]
    next if star.nil?

    year = movie_page.css("a[href^='/year']")[0].content

    score = star.content.gsub(/\n/, '')
    puts "#{title}, #{year}, #{score}"

    sleep Random.rand(5)

  rescue Exception => e
    f.write e.message
    f.write e.backtrace.inspect
  end
end