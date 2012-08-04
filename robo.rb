require 'lib/fun_robo'

@fun_robo = FunRobo.new Table.new(10,10)

if ARGV.any?
  if ARGV.size > 1 #command line parameters are actually commands for Fun Robo
    @commands = ARGV
  else #File name in as parameter that contain all commands
    @commands = open(ARGV[0]).collect
  end
else #lets set sample 1 as default test cases
  @commands = open("sample-input/sample_input_1").collect
end

@commands.each do |command|
  @fun_robo.process_commnad(command.chomp)
end

