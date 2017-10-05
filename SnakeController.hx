import DataStructures;

interface SnakeController { //interface to control snakes
  public function getInputVector():Vector2D; //get the direction to move in
  public function resetInputState():Void; //reset the default starting direction
}
