require 'rspec'
require 'fun_robo'


describe FunRobo do
  let(:table){ TableTop.new}
  let(:robo){ FunRobo.new table }
  subject{ robo }

  context "should not run command before placing on valid position in table" do
    it{ should_not be_ready_for_fun }
    %w[LEFT RIGHT MOVE REPORT].each do |command|
      it{ subject.process_commnad(command).should be_nil }
      it{ subject.send("do_#{command.downcase}").should be_nil }
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
