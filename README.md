fun-robo
========
Play with robot

## Valid Commands 
  * PLACE x,y,face 
  * MOVE 
  * LEFT 
  * RIGHT 
  * REPORT 

## How to run FunRobo
give command to FunRobo using following ways:
  1- give commands as command line arguments 
  2- give commands in a text file(by default sample1.txt would be used if you don't give any file)

Examples(using command line arguments)
  a)
    ruby  robot.rb "PLACE 2,2,NORTH" "MOVE" "REPORT"
    Expected Output:   Output:  2 , 1 , NORTH
  b)
    ruby  robot.rb "Move" "REPORT" "PLACE 2,3,NORTH" "REPORT" "MOVE" "REPORT" "PLACE 2,3,NORTH" "REPORT"
    Expected output: 
         Output:  2 , 3 , NORTH
         Output:  2 , 2 , NORTH
         Output: 2 , 3 , NORTH

Example(using commands in file)
      ruby  robot.rb sample-input/sample_input_1

Expected Output:
  Output:  5 , 7 , SOUTH

