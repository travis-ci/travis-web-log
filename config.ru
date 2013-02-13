require 'sinatra'

set :public_folder, '.'

get '/' do
  send_file File.expand_path('index.html', settings.public_folder)
end

# get '/log' do
#   chars = (97..122).to_a
#   stream do |out|
#     1.upto(10000) do
#       out << chars[rand(chars.length)].chr
#       out << ' ' if rand(5) == 1
#       sleep 0.001
#     end
#   end
# end
