# @date: 2014/12/9
# @author: Steven Zheng

require 'net/http'
require "open-uri"
require "fileutils"
require 'pathname'
require 'pdf-reader'

def download_file(relative_url)
  return unless relative_url
  begin
    puts relative_url
    pdf_files=/([\d]+\.PDF)/.match(relative_url)
    return unless pdf_files
    pdf_file_name=Pathname.new(File.dirname(__FILE__)).realpath.to_s()+"/output/"+pdf_files[0]
    if File::exists?(pdf_file_name)
      pdf_reader = PDF::Reader.new(pdf_file_name)
      return unless pdf_reader
      puts pdf_reader.pdf_version
      puts pdf_reader.page_count
      pdf_reader.pages.each do |page|
        puts page.text
        puts page.raw_content
      end
      return
    end
    puts "Will save to file: " + pdf_file_name
    root="http://www.cninfo.com.cn/"
    full_url=root+relative_url
    puts "Will download file: " + full_url
    open(full_url) { |bin|
      File.open(pdf_file_name, 'w'){ |f|
        while buf = bin.read(1024)
          f.write buf
          STDOUT.flush
        end
       }
    } 
    rescue Exception=>e
      puts "Error happens: #{e}"
      puts "Error is #{$!}"
      puts "Error happens at #{$@}"
  end
end

now=Time.now.strftime("%Y%m%d%H%M")
url="http://www.cninfo.com.cn/disclosure/fulltext/plate/fundlatest_24h.js?ver="+now
url_info=URI.parse(url)
Net::HTTP.start(url_info.host, url_info.port)
content=Net::HTTP.get(url_info)
pdf_files=[]
#pdf_files=content.scan(/\["[\d]+","(finalpage\/[\d-]+\/[\d]+\.PDF)",".*","PDF","[\d]+","[\d-]+","[\d\s-:]+"\]/im)
pdf_files=content.scan(/\["[\d]+","(finalpage\/[\d-]+\/[\d]+\.PDF)","[^\]]+","PDF","[\d]+","[\d\-]+","[\d\-\s:]+"\]/im)
for file in pdf_files
  download_file(file[0]);
end
