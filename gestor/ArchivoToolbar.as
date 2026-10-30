package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	
	public class ArchivoToolbar extends MovieClip {
		
		public const ALTURA:Number=40;
		
		public function ArchivoToolbar() {
			// constructor code
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event=null) {
			bAdd.addEventListener(MouseEvent.CLICK, bAddClick);
			bDelete.addEventListener(MouseEvent.CLICK, bDeleteClick);
		}
		
		public function bAddClick(e:Event=null) {
			if (parent is panelArchivos) {
				(parent as panelArchivos).addFile();
			}
		}
		
		public function bDeleteClick(e:Event=null) {
			if (parent is panelArchivos) {
				(parent as panelArchivos).deleteFiles();
			}
		}
		
	}
	
}
