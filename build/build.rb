files = Array.new

Dir.entries( "../source" ).each do |file|
  files << "../source/#{file}" if file.match /.coffee$/
end

directory = `pwd`.strip!

`coffeescript-concat -l #{directory} #{files.join ' '} -o build.coffee`

`coffee -b -c build.coffee`

`rm build.coffee`

`mv build.js ../bin/task_manager.js`