package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	
	public class BloqueToolbar extends MovieClip {
		
		public const ALTURA:Number=25;
		
		public function BloqueToolbar() {
			// constructor code
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event=null) {
			bAdd.addEventListener(MouseEvent.CLICK, bAddClick);
			bDelete.addEventListener(MouseEvent.CLICK, bDeleteClick);
		}
		
		public function bAddClick(e:Event=null) {
			if (parent is panelHorarios) {
				(parent as panelHorarios).addBloque();
			}
		}
		
		public function bDeleteClick(e:Event=null) {
			if (parent is panelHorarios) {
				(parent as panelHorarios).deleteBloques();
			}
		}
		
	}
	
}
