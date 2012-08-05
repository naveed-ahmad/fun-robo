require 'rspec'
require 'fun_robo'


describe FunRobo do
  let(:table){ TableTop.new}
  let(:robo){ FunRobo.new table }
  subject{ robo }

  describe RoboGuard do
    context "prevent all commands before valid PLACE" do
      it{ should_not be_ready_for_fun }

      %w[LEFT RIGHT MOVE REPORT].each do |command|
        it{ subject.process_command(command).should be_nil }
        it{ subject.send("do_#{command.downcase}").should be_nil }
      end
    end

    context "run commands after valid PLACE" do
      before do
        subject.do_place 2,2,'NORTH'
      end
      
      it{ should be_ready_for_fun }
      %w[LEFT RIGHT MOVE REPORT].each do |command|
        it{ subject.process_command(command).should_not be_nil, "should run #{command}" }
        it{ subject.send("do_#{command.downcase}").should_not be_nil }
      end
    end

  end

  describe 'Robo Commands' do
    context '#Rotation' do
      @faces =  %w[NORTH SOUTH EAST WEST]
      @moves = {'LEFT' => 90,'RIGHT' => -90}
      @face_map = { 0 => 'EAST', 90 =>  'NORTH',180 =>  'WEST',270 => 'SOUTH'}
      def face_map
        { 0 => 'EAST', 90 =>  'NORTH',180 =>  'WEST',270 => 'SOUTH'}
      end
      def moves
        {'LEFT' => 90,'RIGHT' => -90}
      end

      # permute all  possible moves
      @faces.each do |face|
        @moves.keys.each do |move|
          it "change face from #{face} to #{@face_map[(@face_map.index(face) +@moves[move])%360]} with #{move} command" do
            subject.do_place 0,0,face
            subject.send("do_#{move.downcase}").should_not be_nil
            face_map[subject.face].should  ==  face_map[(face_map.index(face) +moves[move])%360]
          end
        end
      end
    end

    context "PLACE" do
      before do
        subject.do_place 1,0,'NORTH'
      end
      
      it "should place Robo in TablePot 3,4 point" do
        subject.do_place(3,4,'WEST').should_not be_nil
        subject.x.should == 3
        subject.y.should == 4
        subject.face.should == 180
      end

      it "should place Robo in on TablePot SOUTH,EAST boundry" do
        subject.do_place(5,5,'EAST').should_not be_nil
        subject.x.should == 5
        subject.y.should == 5
        subject.face.should == 0
      end

      it "should not place Robo on TablePot" do
        subject.do_place(6,6,'EAST').should  be_nil

        #robo should have previous position
        subject.x.should == 1
        subject.y.should == 0
        subject.face.should == 90
      end
    end

    context "MOVE" do
      context "from Northern boundray" do
        before do
          subject.do_place 2,0,'NORTH'
        end
        
        it 'should not move to north' do
          subject.do_move.should be_nil
          subject.face.should == 90
          subject.y.should == 0
        end
        
        it 'should move to east' do
          subject.do_right
          subject.face.should == 0
          subject.do_move.should_not be_nil
          subject.x.should == 3
        end
        
        it 'should move to west' do
          subject.do_left
          subject.face.should == 180
          subject.do_move.should_not be_nil
          subject.x.should == 1
        end

        it 'should move to south' do
          subject.do_left
          subject.do_left
          
          subject.face.should == 270
          subject.do_move.should_not be_nil
          subject.y.should == 1
        end
      end

      context "from Eastren boundray" do
        before do
          subject.do_place 5,2,'EAST'
        end

        it 'should not move to East' do
          subject.do_move.should be_nil
          subject.face.should == 0
          subject.x.should == 5
        end

        it 'should move to North' do
          subject.do_left
          subject.face.should == 90
          subject.do_move.should_not be_nil
          subject.y.should == 1
        end
        
        it 'should move to south' do
          subject.do_right
          subject.face.should == 270
          subject.do_move.should_not be_nil
          subject.y.should == 3
        end

        it 'should move to East' do
          subject.do_left
          subject.do_left

          subject.face.should == 180
          subject.do_move.should_not be_nil
          subject.x.should == 4
        end
      end
    end
  end

  describe "Robo Helpers" do
    #process_command
    it "should accept valid command " do
      subject.process_command("PLACE 3,4,NORTH").should_not be_nil
      subject.process_command("REPORT").should_not be_nil
    end

    it "should ignore invalid command " do
      subject.process_command("PLACE 3,4,NORTH").should_not be_nil
      subject.process_command("FOOBAR").should  be_nil
    end

    it "should be ready after PLACE" do
      subject.should_not be_ready_for_fun
      subject.process_command("PLACE 3,4,NORTH").should_not be_nil
      subject.should be_ready_for_fun
    end
   
    it 'should return valid current_moving_factor' do
      moving_factor_mapping = {:x => ['NORTH', 'SOUTH'],:y => ['EAST','WEST'] }
      moving_factor_mapping.keys do |moving_factor|
        moving_factor_mapping[moving_factor].each do |face|
          subject.process_command("PLACE 3,4,#{face}")
          subject.current_moving_factor.should == moving_factor
        end
      end
    end
  end
end

describe TableTop do
  context 'default agrument' do
    let(:table){ TableTop.new }
    subject{ table }

    it{ subject.is_a?(TableTop).should be_true }
    it{ should be_within_boundry(2,4) }
    it{ should_not be_within_boundry(-2,4) }
    it{ subject.rows.should == 5}
    it{ subject.columns.should == 5}
  end

  context 'should raise ArgumentError on' do
    it 'negative rows' do
      lambda{ TableTop.new(-3, 4)}.should raise_error ArgumentError
    end

    it 'negative columns' do
      lambda{ TableTop.new(3, -4)}.should raise_error ArgumentError
    end

    it 'nil columns value' do
      lambda{ TableTop.new(nil, -4)}.should raise_error ArgumentError
    end

    it 'non-number columns value' do
      lambda{ TableTop.new('test', -4)}.should raise_error ArgumentError
    end
  end

  let(:table){ TableTop.new 4,5 }
  subject{ table }
  it{ should be_within_boundry(3,5) }
  it{ should_not be_within_boundry(5,6) }
  it{ subject.rows.should == 4}
  it{ subject.columns.should == 5}
end
