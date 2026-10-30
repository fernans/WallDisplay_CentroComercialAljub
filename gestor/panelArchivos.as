package  {
	
	import flash.display.MovieClip;
	import flash.filesystem.File;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import fl.containers.ScrollPane;
	
	public class panelArchivos extends MovieClip {
		
		private var files:Array;
		var dir:File;
		public var DIR_MEDIA:String;
		
		public function panelArchivos() {
			// constructor code
			addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		public function init(e:Event=null) {
			DIR_MEDIA=(root as Gestor).DIR_MEDIA;
			
			dir=new File(File.applicationDirectory.nativePath).resolvePath(DIR_MEDIA);
			
			trace("panelArchivos INIT");
			this.removeChildren();
			// add head-toolbar
			var tb:ArchivoToolbar=new ArchivoToolbar();
			this.addChild(tb);
			// add file listing
			loadFiles();
			// add foot-toolbar
			if (this.numChildren>1) {
				tb=new ArchivoToolbar();
				tb.y=this.getChildAt(this.numChildren-1).y+tb.ALTURA;
				this.addChild(tb);
			}
		}
		
		public function loadFiles(e:Event=null) {
			if (!dir.exists) dir.createDirectory();
			files=dir.getDirectoryListing();
			var last:DisplayObject=this.getChildAt(this.numChildren-1);
			for (var i:Number=0;i<files.length;i++) {
				//trace((files[i] as File).name);
				var entry:ArchivoEntry=new ArchivoEntry();
				entry.setFile(files[i]);
				entry.y=last.y+entry.height;
				this.addChild(entry);
				last=entry;
			}
			var p:ScrollPane=(this.parent.parent as ScrollPane);
			if (p!=null) p.update();
		}
		
		// ---------------------------------------------------------------------------------
		
		public function addFile() {
			trace("ADD FILE");
			var nf:File=File.documentsDirectory;
			nf.addEventListener(Event.SELECT, addFileSelected);
			nf.browseForOpen("Selecciona archivo a copiar");
		}
		public function addFileSelected(e:Event) {
			var f:File=(e.target as File);
			if (f!=null) {
				var tf:File=dir.resolvePath(f.name);
				f.addEventListener(Event.COMPLETE, fileComplete);
				(root as Gestor).openAlert("Copiando...");
				f.copyToAsync(tf,true);
			}
		}
		public function fileComplete(e:Event=null) {
			(root as Gestor).closeAlert();
			init(); // reload all
		}
		
		public function deleteFiles() {
			trace("DELETE ALL FILES");
			var f:File=dir;
			f.addEventListener(Event.COMPLETE, fileComplete);
			(root as Gestor).openAlert("Eliminando todo...");
			f.deleteDirectoryAsync(true);
		}
		
		public function deleteFile(f:File) {
			trace("DELETE: "+f.name);
			if ((root as Gestor).isUsed(f.name)) {
				(root as Gestor).openAlert("No se puede eliminar.\nEl archivo se está usando.",true);
				return;
			}
			f.addEventListener(Event.COMPLETE, fileComplete);
			(root as Gestor).openAlert("Eliminando...");
			f.deleteFileAsync();
		}
		
	}
	
}
