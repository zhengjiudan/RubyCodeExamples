# @date: 2014/12/9
# @author: Steven Zheng
# encoding=UTF-8

require "fileutils"
require 'pathname'
require 'pdf-reader'

def process_pdf_page(page)
  return unless page
  page.xobjects.each do |name, stream|
    puts stream.hash[:Subtype]
    case stream.hash[:Subtype]
    when :Form then
      process_pdf_page(PDF::Reader::FormXObject.new(page, stream))
    end
  end
end

def process_pdf_file(pdf_file)
  return unless pdf_file 
  begin
    if File::exists?(pdf_file)
      PDF::Reader.open(pdf_file) do |pdf_reader|
        return unless pdf_reader
        puts pdf_reader.objects.each{ |ref, object| puts object}
#        puts pdf_reader.pages[0].objects.inspect
#        puts pdf_reader.info.inspect
#        puts pdf_reader.metadata.inspect
#        puts pdf_reader.pdf_version
#        puts pdf_reader.page_count
#        puts pdf_reader.pages[0].text.length
#        process_pdf_page(pdf_reader.pages[0])
        pdf_reader.pages[0].objects.deref(pdf_reader.pages[0].attributes[:Resources]).each {|resource| puts resource }
        pdf_reader.pages[0].text.each_line do |line|
          contents = line.encode("gb2312")
#          puts contents.class
#          puts contents	
          profits = /\u{76c8}\u{5229}([\d,\.]+)/u.match(line)
          if profits
            1.upto(profits.length) do |i|
#              puts profits[i-1]
            end
          end
#          contents.split('\r') { |line| puts line }
#        contents.each { |line| puts line }
#        puts page.raw_content
          end
        end
      return
    end
    rescue Exception=>e
      puts "Error happens: #{e}"
      puts "Error is #{$!}"
      puts "Error happens at #{$@}"
  end
end

ARGV.each { |file| process_pdf_file(file) }
