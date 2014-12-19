#encoding: utf-8

str = "\"2014 年度归属于上市公司股东的净利润变动幅度\",-40.00%,至,10.00%"

#match_data = /([\d]{4})[\s]*\u{5e74}\u{5ea6}.*,([\d-\.]+)%.*,([\d-\.]+)%/u.match(str)
match_data = /([\d]{4})[\s]*年度.*变动幅度[^\d]*([\d\.,\-]+)%[^\d]*([\d\.,\-]+)%/.match(str)
puts match_data.length
2.upto match_data.length do |i| 
  puts match_data[i-1]
end

line = "\"2014 年度归属于上市公司股东的净利润变动区间（万元）\",\"9,900.5\",至,\"18,150.91\""
match_data = /([\d]{4})[\s]*年度.*变动区间[^\d]*([\d\.,-]+)[^\d]*([\d\.,-]+)/.match(line)
puts match_data.length
2.upto match_data.length do |i| 
  puts match_data[i-1]
end

puts "I am Steven" =~/Steven/
puts "I am Steven" =~/test/