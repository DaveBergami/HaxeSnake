import DataStructures;

class Snake{

  public var headPosition:Vector2D; //position of head of snake
  public var currentDirection:Vector2D = {x:1,y:0}; //direction of motion
  public var canChangeDirection:Bool=true; //explanation: once a valid direction input is made ,it stays until the next move(), regardless of other inputs after it. this allows a 1 move input buffer.
  public var isDead:Bool=false;
  public var playerID:Int=-1; //initial of -1 (for debug)
  public var tailList:Array<Vector2D>;
  public var previousHeadPosition:Vector2D={x:0,y:0};


  public function new(startPosition:Vector2D,pID:Int){

    headPosition = startPosition;


    playerID = pID;
    tailList = new Array<Vector2D>();
    grow();

  }

  public function changeDirection(input:Vector2D){

    if(canChangeDirection==true){


    if(input.x > 0 && currentDirection.x == 0){
      currentDirection={x:1,y:0};
      canChangeDirection=false;
    }
    else if(input.x < 0 && currentDirection.x == 0){
      currentDirection={x:-1,y:0};
      canChangeDirection=false;
    }
    else if(input.y < 0 && currentDirection.y == 0){
      currentDirection={x:0,y:-1};
      canChangeDirection=false;
    }
    else if(input.y > 0 && currentDirection.y == 0){
      currentDirection={x:0,y:1};
      canChangeDirection=false;
    }




      }
  }

  public function move() : Void {


    previousHeadPosition = {x:headPosition.x,y:headPosition.y};//store current head position
    headPosition.x += currentDirection.x*GameConstants.snakeSize;//move head
    headPosition.y += currentDirection.y*GameConstants.snakeSize;
    canChangeDirection=true;

    updateTail();

  }

  public function kill() : Void {
    isDead=true;
  }

  public function updateTail() : Void {

    var previousPositionTemp:Vector2D={x:0,y:0};
    var previousPositionTemp2:Vector2D={x:0,y:0};

      for(i in 0...tailList.length){


          if(i==0){ //first segment follows head
            previousPositionTemp=tailList[i];
            tailList[i]=previousHeadPosition;
          }
          else{ //other segments follow in a chain
            previousPositionTemp2=previousPositionTemp;
            previousPositionTemp=tailList[i];
            tailList[i]=previousPositionTemp2;
          }
      }
  }



  public function grow() : Void {

    tailList.push({x: headPosition.x , y: headPosition.y});

  }



}
