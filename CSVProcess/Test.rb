str="\"I am Steven\""
puts "Original string is #{str}"

new_str = str.gsub(/\"/, '')
puts "The string after replace is #{new_str}"

