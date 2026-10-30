package  {
	
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import fl.text.TLFTextField;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class Alert extends MovieClip {
		
		public function Alert(p:DisplayObject=null, mensaje:String="") {
			if (p!=null && p.stage!=null) {
				p.stage.addChild(this);
				this.y=(p.stage.stageHeight+this.height)/2;
				this.x=(p.stage.stageWidth+this.width)/2;
				this.texto.text=mensaje;
			}
			bOk.addEventListener(MouseEvent.CLICK, bOkClick);
		}
		
		public function open(mensaje:String="", showOk:Boolean=false) {
			texto.text=mensaje;
			bOk.visible=showOk;
			visible=true;
		}
		
		public function close() {
			visible=false;
		}
		
		private function bOkClick(e:Event=null) {
			close();
		}
		
	}
}
