package  {
	
	import flash.display.MovieClip;
	import flash.filesystem.File;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class ArchivoEntry extends MovieClip {
		
		private var file:File;
		
		public function ArchivoEntry() {
			// constructor code
		}
		
		public function getFile():File {
			return file;
		}
		public function setFile(f:File):void {
			file=f;
			title.text=file.name;
			if (file.type==".jpg" || file.type==".png") {
				fileIcon.gotoAndStop(2);
			} else if (file.type==".mov" || file.type==".flv") {
				fileIcon.gotoAndStop(3);
			} else fileIcon.gotoAndStop(0); // unknown;
			
			bDelete.addEventListener(MouseEvent.CLICK, bDeleteClick);
		}
		
		public function bDeleteClick(e:Event=null) {
			if (parent is panelArchivos) {
				(parent as panelArchivos).deleteFile(file);
			}
		}
	}
	
}
