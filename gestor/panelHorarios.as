package  {
	
	import flash.display.MovieClip;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import fl.containers.ScrollPane;
	
	public class panelHorarios extends MovieClip {
		
		var dir:File;
		var media:File;
		var doc:XML;
		var docPlan:XML=null;
		var plan:Number=0;
		
		const DEFAULT_IMAGE_TIME:Number=5;
		public var DIR_MEDIA:String;
		public var DOC_XML:String;
		
		public function panelHorarios() {
			// constructor code
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event=null) {
			DOC_XML=(root as Gestor).DOC_XML;
			DIR_MEDIA=(root as Gestor).DIR_MEDIA;
			
			dir=new File(File.applicationDirectory.nativePath).resolvePath(DOC_XML);
			trace(dir.nativePath);
			media=new File(File.applicationDirectory.nativePath).resolvePath(DIR_MEDIA);
			trace(media.nativePath);
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			trace("panelHorarios INIT");
			loadDoc();
		}
		
		public function copiar(destino:Number=NaN) {
			if (!isNaN(destino) && !isNaN(plan) && destino!=plan) {
				// no existen tantos planes (hasta destino) todavia
				while (doc.plan.length()<=destino) {
					docPlan=<plan/>;
					doc.appendChild(docPlan);
				}
				// copiar plan actual al destino
				docPlan=doc.plan[plan]; // el actual
				doc.plan[destino]=docPlan.copy();
				plan=destino;
				saveDoc();
			}
		}
		
		public function saveDoc() { //e:Event=null) {
			// save doc
				var fs:FileStream=new FileStream();
				trace("  WRITING CONFIG FILE TO: "+dir.nativePath);
				fs.open(dir,FileMode.WRITE);
				fs.writeUTFBytes(doc.toXMLString());
				//doc=XML(fs.readUTFBytes(fs.bytesAvailable));
				fs.close();
				parseDoc();
		}
		
		public function loadDoc() { //e:Event=null) {
			if (!dir.exists) return; // empty doc
			// load doc
				var fs:FileStream=new FileStream();
				trace("  READING CONFIG FILE FROM: "+dir.nativePath);
				fs.open(dir,FileMode.READ);
				doc=XML(fs.readUTFBytes(fs.bytesAvailable));
				fs.close();
				parseDoc();
		}
		public function parseDoc() { //e:Event=null) {
			this.removeChildren();
			// parse planes
			var barraPlanes:HorarioPlanes=new HorarioPlanes();
			barraPlanes.activar(plan);
			this.addChild(barraPlanes);
			docPlan=null;
			docPlan=doc.plan[plan];
			if (docPlan==null) {
				while (doc.plan.length()<=plan) {
					docPlan=<plan/>;
					doc.appendChild(docPlan);
				}
			}
				// parse bloques
				trace("cargando bloques del plan "+plan);
					var posy:Number=barraPlanes.ALTURA;
					var bloque:XML=null;
					for (var b:int=0;b<docPlan.bloque.length();b++) {
						// para cada bloque
						bloque=docPlan.bloque[b];
						var entryBloque:BloqueEntry=new BloqueEntry();
						entryBloque.setXml(bloque);
						entryBloque.y=posy;
						posy+=entryBloque.ALTURA;
						this.addChild(entryBloque);
						//---
						var hora:Number=bloque.@hora;
						var random:Boolean=bloque.@random;
						for (var i:int=0;i<bloque.content.length();i++) {
							// para cada file del bloque
							var url:String=bloque.content[i].@url;
							var time:Number=bloque.content[i].@time;
							var entry:HorarioEntry=new HorarioEntry(this.DIR_MEDIA);
							entry.setXml(bloque.content[i]);
							entry.y=posy;
							posy+=entry.height;
							this.addChild(entry);
						} // for file del bloque
						var tb:HorarioToolbar=new HorarioToolbar(bloque);
						tb.y=posy;
						posy+=tb.ALTURA;
						this.addChild(tb);
					} // for cada bloque
				// fin parse bloques
			// foot toolbar
				var tbb:BloqueToolbar=new BloqueToolbar();
				tbb.y=posy
				this.addChild(tbb);
			// update scroll pane
			var p:ScrollPane=(this.parent.parent as ScrollPane);
			if (p!=null) p.update();
		}
		
		// ---------------------------------------------------------------------------------
		
		private var tempAddBloque:XML;
		public function addItem(b:XML=null) {
			trace("ADD FILE");
			tempAddBloque=b;
			tempEntry=null;
			selectFile();
		}
		private function selectFile() {
			var nf:File=new File(media.nativePath);
			nf.addEventListener(Event.SELECT, addFileSelected);
			nf.browseForOpen("Selecciona archivo a asignar");
		}
		public function addFileSelected(e:Event) {
			var f:File=(e.target as File);
			if (f!=null) {
				var tf:File=media.resolvePath(f.name);
				if (tf.exists) {
					if (tempEntry!=null) { // change
						tempEntry.@url="media/"+f.name;
					} else { // new
						var entry:XML=<content/>;
						entry.@url="media/"+f.name;
						entry.@time=DEFAULT_IMAGE_TIME;
						tempAddBloque.appendChild(entry);
					}
					saveDoc();
				} else {
					(root as Gestor).openAlert("El archivo debe estar en:\n"+media.nativePath, true);
				}
			}
		}
		
		private var tempEntry:XML=null;
		public function changeUrl(i:XML,wasVideo:Boolean) {
			tempEntry=i;
			if (wasVideo) tempEntry.@time=this.DEFAULT_IMAGE_TIME;
			tempAddBloque=null;
			selectFile();
		}
		
		// -----------------------------------------------------
		
		public function deleteItems(bloque:XML) {
			trace("DELETE ALL FILES");
			bloque.setChildren(new XMLList());
			saveDoc();
		}
		
		public function deleteItem(i:XML) {
			trace("DELETE: "+i.@url);
			var index:Number=i.childIndex();
			var p:XML=i.parent();
			var children:XMLList=p.children();
			delete children[index];
			saveDoc();
		}
		
		public function upItem(i:XML) {
			trace("UP:");
			var index:Number=i.childIndex();
			if (index>0) {
				var p:XML=i.parent();
				var hermano:XML=p.children()[index-1];
				if (hermano!=null) {
					p.replace(index,hermano);
					p.replace(index-1,i);
					saveDoc();
				}
			}
		}
		public function downItem(i:XML) {
			trace("DOWN");
			var index:Number=i.childIndex();
			var p:XML=i.parent();
			var children:XMLList=p.children();
			if (index<children.length()) {
				var hermano:XML=p.children()[index+1];
				if (hermano!=null) {
					p.replace(index,hermano);
					p.replace(index+1,i);
					saveDoc();
				}
			}
		}
		
		// -----------------------------------------------------
		
		public function addBloque() {
			trace("ADD Bloque");
			var b:XML=<bloque/>;
			b.@hora=0;
			b.@random=false;
			docPlan.appendChild(b);
			trace(docPlan.toXMLString());
			if (docPlan.children().length()>1)
				ordenarBloque(b);
			else saveDoc();
		}
		
		public function deleteBloque(b:XML) {
			trace("DELETE: "+b.@hora);
			var index:Number=b.childIndex();
			var p:XML=b.parent();
			var children:XMLList=p.children();
			delete children[index];
			saveDoc();
		}
		
		public function deleteBloques() {
			trace("DELETE Bloques");
			docPlan.setChildren(new XMLList());
			trace(docPlan.toXMLString());
			saveDoc();
		}
		
		public function ordenarBloque(b:XML) {
			var p:XML=b.parent();
			var children:XMLList=p.children();
			if (children.length()>1) {
				// borrar bloque de donde estara
				var index:Number=b.childIndex();
				delete children[index];
				// buscar donde meterlo
				var siguiente:XML;
				for (index=0;index<children.length();index++) {
					siguiente=children[index];
					if (Number(siguiente.@hora)>Number(b.@hora)) {
						p.insertChildBefore(siguiente,b);
						trace("insertado antes de: "+siguiente.@hora);
						break; // salir del bucle
					}
				}
				if (index==children.length()) {
					// salio del bucle sin encontrar alguien posterior
					// poner este como el ultimo
					trace("insertado al final");
					p.appendChild(b);
				}
			}
			saveDoc();
		}
		
	}
	
}
