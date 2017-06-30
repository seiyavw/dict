require 'nokogiri'
require 'open-uri'
require 'net/http'


#注意: かなりてきとう

index = Nokogiri::HTML(open(INDEX_URL))
BASE_URL = 'https://developers.maxon.net/docs/Cinema4DPythonSDK/html/'.freeze
INDEX_URL = BASE_URL + 'index.html'.freeze

res = Net::HTTP.get_response(URI.parse(INDEX_URL))
if res.code != '200'
  puts "status error : " + res.code.to_s
  exit
end

index = Nokogiri::HTML(open(INDEX_URL))
link_tags = index.xpath('//a[contains(text(), "module - ")]')

items = []

link_tags.each do |tag|

  url = URI.escape(BASE_URL + tag[:href])

  # 1st page
  doc = Nokogiri::HTML(open(url))

  # normal
  doc.search('[id="types"]//[class="simple"]//a').each do |sub|

    suburl = URI.join(url, sub[:href]).to_s

    puts "url :" + suburl

    #2nd
    doc2 = Nokogiri::HTML(open(suburl))

    puts "put : " + sub.inner_text
    items << sub.inner_text

    doc2.search('[class="simple"]//a').each do |item|
      sp = item.inner_text.split('.')
      puts "put : " + sp.last
      items << sp.last
    end
  end

  doc.search('[id="functions"]//[class="simple"]//a').each do |sub2|
    puts "put : " + sub2.inner_text
    items << sub2.inner_text
  end

  # c4d modules
  if tag.inner_text == 'module - c4d.modules' then
    #1st
    doc.search('[id="c4d-modules"]//td//a').each do |sub|

      suburl = URI.join(url, sub[:href]).to_s

      #2nd
      doc2 = Nokogiri::HTML(open(suburl))

      doc2.search('[id="types"]//[class="simple"]//a').each do |sub2|

        suburl2 = URI.join(suburl, sub2[:href]).to_s

        #3rd
        doc3 = Nokogiri::HTML(open(suburl2))

        puts "put : " + sub2.inner_text
        items << sub2.inner_text

        doc3.search('[id="types"][class="simple"]//a').each do |item|

          sp = item.inner_text.split('.')

          puts "put : " + sp.last
          items << sp.last

          suburl3 = URI.join(suburl2, item[:href]).to_s

          doc4 = Nokogiri::HTML(open(suburl3))

          doc4.search('[class="simple"]//a').each do |sub3|
            sp2 = sub3.inner_text.split('.')
            puts "put : " + sp2.last
            items << sp2.last
          end

        end

        doc3.search('[id="functions"]//[class="simple"]//a').each do |item|
          puts "put : " + item.inner_text
          items << item.inner_text
        end

      end

      doc2.search('[id="functions"]//[class="simple"]//a').each do |sub2|
        puts "put : " + sub2.inner_text
        items << sub2.inner_text
      end

    end
  end

end

File.open('c4d.dict', 'w') do |f|
  items.uniq!.sort!
  items.each { |item| f.puts(item) }
end
