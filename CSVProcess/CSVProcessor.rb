﻿#encoding: utf-8

require 'win32ole'

class IndividualCompany
  attr_reader :net_profit
  attr_reader :percentage_from
  attr_reader :percentage_to
  attr_reader :change_from
  attr_reader :change_to
  attr_reader :net_profit_last_year
  attr_reader :this_year
  attr_reader :last_year
  attr_reader :reason
  
  def initialize(content)
    content.each do |line|
      match_data = /([\d]{4})[\s]*年度.*变动区间[^\d]*[,|\"]([\d\.,\-]+)[^\d]*([\d\.,\-]+)/.match(line)
      if match_data
        @this_year = match_data[1]
        @change_from = match_data[2]
        @change_to = match_data[3]
        next
      end
      
      match_data = /([\d]{4})[\s]*年度.*变动幅度[^\d]*[,|\"]([\d\.,\-]+)%[^\d]*([\d\.,\-]+)%/.match(line)
      if match_data
        @this_year = match_data[1]
        @percentage_from = match_data[2]
        @percentage_to = match_data[3]
        next
      end
      
      match_data = /([\d]{4})[\s]*年度.*净利润[^\d]*([\d\.,\-]+)/.match(line)
      if match_data
        @last_year = match_data[1]
        @net_profit_last_year = match_data[2]
        next
      end
      
      match_data = /.*原因[^\d]*,(.*)/.match(line)
      if match_data
        @reason = match_data[1]
        next
      end
    end
  end
end

class ContentParser
  def initialize()
    @companies = {}
  end
  
  def add_report(company_name, content)
    company = IndividualCompany.new(content)
    companies[company_name] = company
  end
  
  def create_excel_report()
    if File.exist?('c:\temp\test.xlsx')
      File.rename('c:\temp\test.xlsx', 'c:\temp\test_old.xlsx')
    end
    excel = WIN32OLE::new('excel.Application')
    excel.visible = false
    workbook = excel.workbooks.add
    workbook.saveas('c:\temp\test.xlsx')
    worksheet = workbook.Worksheets(1)
    worksheet.select
    
    index=1
    companies.each do |company_name, company|
      worksheet.Range('a#{index}')['Value'] = company_name
      worksheet.Range('b#{index}')['Value'] = "gives " + company.this_year + " net profit outlook"
      worksheet.Range('c#{index}')['Value'] = "Sees net profit for " + company.this_year +
       " to increase by " + company.percentage_from + " pct to " + company.percentage_to + " pct, " +
       " or to be " + company.change_from + " yuan to " + company.change_to + " yuan "
      worksheet.Range('d#{index}')['Value'] = "Says the net profit of " + company.last_year + " was " + company.net_profit_last_year + " yuan "
      worksheet.Range('e#{index}')['Value'] = "Comments that " + company.reason + " as the main reason for the forecast"
      index=index+1
    end

    workbook.Close(1)
    excel.Quit
  end
eend


def parse_content(contents)
  contents.each do |line|
    str_array = line.split(',');
    next unless str_array.length > 1
    
    match_data = /([\d]{4})[\s]*年度.*变动区间/.match(str_array[0])
    if match_data
      puts "this year #{match_data[1]}"
      2.upto str_array.length do |i|
      	str_array[i-1].gsub('"', '')
      	match_data = /[^\d]*([\d\.,\-]+)/.match(str_array[i-1])
      	next unless match_data
      	puts match_data[1]
      end
    end
  end
end

content = ["\"2014 年度归属于上市公司股东的净利润变动幅度\",-40.00%,至,10.00%",
           "\"2014 年度归属于上市公司股东的净利润变动区间（万元）\",\"9,900.5\",至,\"18,150.91\"",
           "\"2013 年度归属于上市公司股东的净利润（万元\",\"16,500.83\"",
           "业绩变动的原因说明,\"（1）营业收入比上年同期将有一定的增加；（2）资产减值损失较上年同期有较大幅度的增加；（3）取得的政府补助较上年同期有一定幅度的下降。\""
           ]

company = IndividualCompany.new(content)
puts company.this_year
puts company.net_profit
puts company.last_year
puts company.net_profit_last_year
puts company.percentage_from
puts company.percentage_to
puts company.change_from
puts company.change_to
puts company.reason

content_parser = ContentParser.new()
content_parser.add_report("TR", content)
content_parser.create_excel_report()