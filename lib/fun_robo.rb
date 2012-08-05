class TableTop
  attr_accessor :rows,:columns
  def initialize(rows = 5, columns = 5)
    raise ArgumentError.new("rows are invalid( should be > 1)") unless rows && rows.is_a?(Fixnum) && rows > 1
    raise ArgumentError.new("columns are invalid( should be > 1)") unless columns && rows.is_a?(Fixnum) && columns > 1

    @rows, @columns = rows, columns
  end

  def within_boundry?(x,y)
    (0 .. rows).include? x.to_i  and (0 .. columns).include? y.to_i
  end
end

module RoboGuard
  def guard_methods(guard_method_name,*methods_to_guard)
    guard  =  instance_method guard_method_name
    methods_to_guard.each do |name|
      m = instance_method(name)
      define_method(name) do |*args, &block|
        yield if block_given?
        m.bind(self).call(*args, &block) if guard.bind(self).call
      end
    end
  end
end

module RoboCommands
  
  def do_place(*args)
    args = args[0].split  ',' if args.size == 1 && args[0].is_a?(String)
    x  = args[0].to_i rescue nil
    y  = args[1].to_i rescue nil
    valid_face = @face_map.index args[2].to_s.upcase

    if valid_face && @table.within_boundry?(x, y)
      @x,@y,@face = x,y,valid_face
    end
  end

  def do_move
    case current_moving_factor
    when :x
      @x += @movement_map[@face] if @table.within_boundry?(@x + @movement_map[@face] , @y)
    when :y
      @y += @movement_map[@face] if @table.within_boundry?(@x , @y + @movement_map[@face])
    end
  end
  
  def do_left
    @face = (@face + 90) % 360
  end

  def do_right
    @face = (@face - 90) % 360
  end

  def do_report
    puts "Output:  #{@x} , #{@y} , #{@face_map[@face]}"
    true
  end
end

class FunRobo
  extend RoboGuard
  include RoboCommands

  attr_reader :x, :y, :face, :table
  
  def initialize(table)
    @table = table
    @movement_map = {0 => 1, 90 =>  -1,180 => -1,270 => 1}
    @face_map = { 0 => 'EAST', 90 =>  'NORTH',180 =>  'WEST',270 => 'SOUTH'}
  end

  def process_command(command_str)
    command_parts = command_str.split ' '
    command,args = command_parts[0], command_parts[1]
    if command_parts.any?
      return do_place(args) if command == 'PLACE'

      begin
        self.send "do_#{command.downcase}"  if ready_for_fun?
      rescue NoMethodError => e
        nil
      end
    end
  end

  def ready_for_fun?
    !!( @x and @y and @face)
  end

  def current_moving_factor
    [0,180].include?(@face) ? :x : :y
  end

  # lets guard robo commands with ready_for_fun
  guard_methods 'ready_for_fun?',*(RoboCommands.instance_methods-['ready_for_fun?','do_place'])
end

