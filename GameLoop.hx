import flash.Lib;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.display.Stage;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import DataStructures;

class GameLoop {

static var flashstage:Stage = Lib.current.stage;
var canvas:flash.display.MovieClip;

var listOfPlayers:Array<SnakeController>;
var listOfSnakes:Array<Snake>;
var listofSnakesToRemove:Array<Snake>;
var apple:Vector2D;
var tickCount = 0;
var gameResetFlag:Bool = false;
var textDisplay:TextField;
var isGameOver:Bool=false;
var gameOverTimer=-1; //when time is 0, game is reset.
var cellsInPlayfield:Int;
var cellsOccupied:Int=0;

public function new() {
//
  flashstage.addEventListener(Event.ENTER_FRAME, frameUpdate);


  canvas = flash.Lib.current;

  var messageFormat:TextFormat = new TextFormat("Verdana", 18, 0xEEEEEE, true);
  messageFormat.align = TextFormatAlign.CENTER;

  textDisplay = new TextField();
  canvas.addChild(textDisplay);
  textDisplay.width = 500;
  textDisplay.y = 450;
  textDisplay.defaultTextFormat = messageFormat;
  textDisplay.selectable = false;
  textDisplay.text = "SNAKE";
// initialize flash stuff
  //initial the list of players
  listOfPlayers = new Array<SnakeController>();

  //add 2 keyboard players
  listOfPlayers.push(new KeyBoardPlayer(37,39,38,40));
  listOfPlayers.push(new KeyBoardPlayer(65,68,87,83));

  //initialize the list of snakes and snakesToRemove (deletion buffer so we don't delete while iterating over the snakes)
  listOfSnakes = new Array<Snake>();
  listofSnakesToRemove = new Array<Snake>();

  cellsInPlayfield= Math.floor((GameConstants.boardSize/GameConstants.snakeSize)*(GameConstants.boardSize/GameConstants.snakeSize)); //compute total number of cells

  resetGameState(); //initialize and start the game for the first time



}

private function frameUpdate(e:Event) {
tickCount++;

controlUpdate(); //update input at 60 fps
if(tickCount%4==0) //let game logic update at a slower rate
{

  if(isGameOver==false)
  {
    moveSnakes();
    checkWallCollision();
    checkTailCollision();
    deleteDeadSnakes();
    checkAppleCollision();
    computeOccupiedCells();
    checkWinConditions();
  }


}
tickTimers();//let timers at 60 fps
gfxUpdate();//let graphics update at 60 fps
}

public function gfxUpdate() { //simple graphics
  canvas.graphics.clear();
  for (snake in listOfSnakes)
  {

      canvas.graphics.beginFill(0x770000+((snake.playerID-1)*500000));
      canvas.graphics.drawRect(snake.headPosition.x, snake.headPosition.y, GameConstants.snakeSize, GameConstants.snakeSize);

      for(tail in snake.tailList){
        canvas.graphics.beginFill(0x990000+((snake.playerID-1)*500000));
        canvas.graphics.drawRect(tail.x, tail.y, GameConstants.snakeSize, GameConstants.snakeSize);
      }


  }

  canvas.graphics.beginFill(770000);
  canvas.graphics.drawRect(apple.x, apple.y, GameConstants.snakeSize, GameConstants.snakeSize);

}

public function tickTimers(){ //timers for stuff like gameover
  if(gameOverTimer>0){
    gameOverTimer--;
    if(gameOverTimer <= 0){
      gameOverTimer=-1;
      isGameOver=false;
      resetGameState();
    }
  }
}

public function moveSnakes(){
  for (snake in listOfSnakes)
  {

      snake.move();


  }
}

public function checkWinConditions(){//evaluate game state



    var numDeadPlayers= listOfPlayers.length - listOfSnakes.length;


    //if(listOfPlayers.length==1){ //normal rules
      if(listOfSnakes.length==0){
        gameOverTimer=60;
        isGameOver=true;
        showWinMessage("Game Over!");
      }

      if(cellsOccupied==cellsInPlayfield){
        gameOverTimer=60;
        isGameOver=true;
        showWinMessage("Winner!");
      }
    //}
    //battle mode rules
    // else if(listOfPlayers.length>1){ //multiplayer rules.
    //   if(listOfSnakes.length==1){ //all but one are dead
    //     showWinMessage("Player " + (listOfSnakes[0].playerID+1) + " Won!");
    //     gameOverTimer=60;
    //     isGameOver=true;
    //   }else if(listOfSnakes.length==0) {// all died on the same frame
    //     showWinMessage("Nobody Won! Draw!");
    //     gameOverTimer=60;
    //     isGameOver=true;
    //   }
    // }


}

public function checkWallCollision(){
  for (snake in listOfSnakes)
  {
        if(
              snake.headPosition.x < GameConstants.walls.left
            ||(snake.headPosition.x+GameConstants.snakeSize) > GameConstants.walls.right
            ||snake.headPosition.y < GameConstants.walls.top
            ||(snake.headPosition.y+GameConstants.snakeSize) > GameConstants.walls.bottom
          )
          {
            snake.kill();
            removeSnake(snake);
          }
  }
}

public function checkTailCollision(){
  for (snake in listOfSnakes)
  {
      for(othersnake in listOfSnakes)
      { //check collisions between all snake x snake

            if(snake!=othersnake) //if we aren't checking a snake against itself
            {
                      if(   //head/head intersection
                          snake.headPosition.x == othersnake.headPosition.x
                          &&snake.headPosition.y == othersnake.headPosition.y
                        )

                        {
                          snake.kill();
                          removeSnake(snake);
                        }

                        for(tail in othersnake.tailList)
                        {

                          if(   //head/enemy tail intersection
                              snake.headPosition.x == tail.x
                            &&snake.headPosition.y == tail.y
                            )

                            {
                              snake.kill();
                              removeSnake(snake);
                            }

                        }


            }



      }

      for(tail in snake.tailList)
      {

        if(   //head/own tail intersection
            snake.headPosition.x == tail.x
          &&snake.headPosition.y == tail.y
          )

          {
            snake.kill();
            removeSnake(snake);
          }

      }


  }
}

public function checkAppleCollision(){
  for (snake in listOfSnakes)
  {
        if(
               snake.headPosition.x == apple.x
            && snake.headPosition.y == apple.y
          )
          {
            snake.grow();
            makeNewApple();
          }
  }
}

public function makeNewApple(){


  var appleTestPosition:Vector2D = {x:0,y:0};
  var foundPosition:Bool=false;

while(!foundPosition)
{ //brute force a new random position if the tested one is occupied until it finds a free space. Not the best but it's fine for this

  appleTestPosition.x = Math.floor((Math.random()*(GameConstants.boardSize/GameConstants.snakeSize)))*GameConstants.snakeSize;
  appleTestPosition.y = Math.floor((Math.random()*(GameConstants.boardSize/GameConstants.snakeSize)))*GameConstants.snakeSize;

  foundPosition=true;
  for (snake in listOfSnakes)
  {
        if(
               snake.headPosition.x == appleTestPosition.x
            && snake.headPosition.y == appleTestPosition.y
          )
          {
            foundPosition=false;
            break;
          }
          for(tail in snake.tailList)
          {
            if(
                   tail.x == appleTestPosition.x
                && tail.y == appleTestPosition.y
              )
              {
                foundPosition=false;
                break;
              }

          }
  }
}


    apple = appleTestPosition;
}

public function resetGameState(){

  makeNewApple();

  textDisplay.text = "SNAKE";
  listOfSnakes = [];

  var startoffset=0;

  for (i in 0...listOfPlayers.length)
  {
    listOfPlayers[i].resetInputState();
    var playerStartPosition = {x:0, y:0+startoffset}; //p1 start pos
    listOfSnakes.push(new Snake(playerStartPosition,i)); //create a snake for each player
    startoffset += GameConstants.snakeSize*3; //move start position for next player
  }
}

public function controlUpdate(){

  for(snake in listOfSnakes){

    snake.changeDirection(listOfPlayers[snake.playerID].getInputVector());
  }
}

public function showWinMessage(msg:String){

  textDisplay.text = msg;
}

public function removeSnake(snake:Snake){
  listofSnakesToRemove.push(snake);
}

public function deleteDeadSnakes(){


  for(deadSnake in listofSnakesToRemove){

    listOfSnakes.remove(deadSnake);

  }

}

  public function computeOccupiedCells(){
    cellsOccupied=0;
    for(snake in listOfSnakes)
    {
      cellsOccupied++;
      for(tail in snake.tailList)
      {
        cellsOccupied++;
      }
    }



  }


}
