require 'json'

source = ARGV[0]
target = source.split('.').insert(1, 'parts').join('.').sub('.txt', '.js')
parts  = JSON.parse(File.read(source))['log']['parts']

File.open(target, 'w+') do |f|
  f.write("[\n")
  parts.each do |part|
    f.write("  #{JSON.dump([part['number'], part['content']])},\n")
  end
  f.write("]\n")
end
