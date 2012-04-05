require 'rubygems'
require 'sparklines'

values = []
File.open(ARGV[0],'r'){|f|
    while (line = f.gets)
      values << line.chomp.split(' ')[-1].to_f
    end
  }

name = ARGV[0].split('/')[-1].split('.')[0]
# write the values to a file.  
Sparklines.plot_to_file("plots/images/#{name}.png",values, :type => 'smooth', :height => '54', :background_color => '#073642',:line_color => '#eee8d5')