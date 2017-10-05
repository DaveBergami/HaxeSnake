import flash.Lib;
import flash.events.Event;
import flash.events.KeyboardEvent;
import DataStructures;
import flash.display.Stage;

class KeyBoardPlayer implements SnakeController{ //control input from a keyboard

  static var keyBoolState:Array<Bool>=[];
  static var keyFrameDuration:Array<Int>=[];
  static var isKeyboardInputInitialized=false;
  static var flashstage:Stage = Lib.current.stage;

  var playerArrowUp=0;
  var playerArrowDown=0;
  var playerArrowLeft=0;
  var playerArrowRight=0;
  var currentVector:Vector2D = {x:1,y:0};


  public function new(l:Int,r:Int,u:Int,d:Int){ //constructor sets which keys the player uses

    playerArrowRight=r;
    playerArrowLeft=l;
    playerArrowDown=d;
    playerArrowUp=u;

    if(isKeyboardInputInitialized==false){ //if the event handlers aren't set yet do that the first time a Keyboard player is created

      flashstage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
      flashstage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
      flashstage.addEventListener(Event.ENTER_FRAME, keyboardDurationStateUpdate);
      isKeyboardInputInitialized=true;

    }


  }

  public static function onKeyDown(e:KeyboardEvent):Void{
    keyBoolState[e.keyCode] = true;
    }
  public static function onKeyUp(e:KeyboardEvent):Void{
    keyBoolState[e.keyCode] = false;
    }
  public static function keyboardDurationStateUpdate(e:Event):Void{
      for(i in 0...keyBoolState.length){ //update the array which contains the amount of time in frames each key was held.
        if(keyBoolState[i]){
          keyFrameDuration[i] += 1;
        }
        else keyFrameDuration[i]=0;
      }
    }

  public function getInputVector(){

    var controlVector:Vector2D=currentVector; //defaults to last direction

    if(keyFrameDuration[playerArrowRight]==1){ //register an input only on first frame it's down
      controlVector={x:1,y:0};
    }
    else if(keyFrameDuration[playerArrowLeft]==1){
      controlVector={x:-1,y:0};
    }
    else if(keyFrameDuration[playerArrowUp]==1){
      controlVector={x:0,y:-1};
    }
    else if(keyFrameDuration[playerArrowDown]==1){
      controlVector={x:0,y:1};
    }

    currentVector=controlVector;
    return controlVector;

  }

  public function resetInputState(){
    currentVector = {x:1,y:0};
  }
}
