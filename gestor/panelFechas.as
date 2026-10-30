package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import fl.containers.ScrollPane;
	
	public class panelFechas extends MovieClip {
		
		var dir:File;
		var doc:XML;
		var docDias:XML;
		var docFechas:XML;
	
		public var DOC_XML:String;
		
		
		public function panelFechas() {
			// constructor code
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event=null) {
			DOC_XML=(root as Gestor).DOC_XML;
			
			dir=new File(File.applicationDirectory.nativePath).resolvePath(DOC_XML);
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			trace("panelFechas INIT");
			loadDoc();
			
			cLunes.addEventListener(Event.CHANGE, cambiarPlan);
			cMartes.addEventListener(Event.CHANGE, cambiarPlan);
			cMiercoles.addEventListener(Event.CHANGE, cambiarPlan);
			cJueves.addEventListener(Event.CHANGE, cambiarPlan);
			cViernes.addEventListener(Event.CHANGE, cambiarPlan);
			cSabado.addEventListener(Event.CHANGE, cambiarPlan);
			cDomingo.addEventListener(Event.CHANGE, cambiarPlan);
			
			bAdd.addEventListener(MouseEvent.CLICK, addFecha);
			bDelete.addEventListener(MouseEvent.CLICK, deleteFechas);
		}
		
		private function cambiarPlan(e:Event) {
			var dia:XML;
			switch(e.target) {
				case cLunes: dia=docDias.lunes[0]; break;
				case cMartes: dia=docDias.martes[0]; break;
				case cMiercoles: dia=docDias.miercoles[0]; break;
				case cJueves: dia=docDias.jueves[0]; break;
				case cViernes: dia=docDias.viernes[0]; break;
				case cSabado: dia=docDias.sabado[0]; break;
				case cDomingo: dia=docDias.domingo[0]; break;
			}
			if (dia!=null) {
				dia.@plan=e.target.selectedItem.data;
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
			holder.removeChildren();
			// parse dias
			docDias=null;
			docDias=doc.dias[0];	// solo tomar el 1er bloque dias (si es que hay mas, que no deberia)
			if (docDias==null) {
				docDias=<dias>
							<lunes plan="0" />
							<martes plan="0" />
							<miercoles plan="0" />
							<jueves plan="0" />
							<viernes plan="0" />
							<sabado plan="0" />
							<domingo plan="0" />
						</dias>;
				doc.appendChild(docDias);
			}
			if (docDias.lunes!=null && docDias.lunes[0].@plan!=undefined) cLunes.selectedIndex=docDias.lunes[0].@plan;
			if (docDias.martes!=null && docDias.martes[0].@plan!=undefined) cMartes.selectedIndex=docDias.martes[0].@plan;
			if (docDias.miercoles!=null && docDias.miercoles[0].@plan!=undefined) cMiercoles.selectedIndex=docDias.miercoles[0].@plan;
			if (docDias.jueves!=null && docDias.jueves[0].@plan!=undefined) cJueves.selectedIndex=docDias.jueves[0].@plan;
			if (docDias.viernes!=null && docDias.viernes[0].@plan!=undefined) cViernes.selectedIndex=docDias.viernes[0].@plan;
			if (docDias.sabado!=null && docDias.sabado[0].@plan!=undefined) cSabado.selectedIndex=docDias.sabado[0].@plan;
			if (docDias.domingo!=null && docDias.domingo[0].@plan!=undefined) cDomingo.selectedIndex=docDias.domingo[0].@plan;
			
			// parse fechas
			docFechas=null;
			docFechas=doc.fechas[0]; // solo tomar el 1er bloque fechas (si es que hay mas, que no deberia)
			if (docFechas==null) {
				docFechas=<fechas/>;
				doc.appendChild(docFechas);
			}
			// parse bloques
			trace("cargando fechas");
				var posy:Number=0; //barraPlanes.ALTURA;
				var fecha:XML=null;
				for (var b:int=0;b<docFechas.fecha.length();b++) {
					// para cada bloque
					fecha=docFechas.fecha[b];
					var entry:FechaEntry=new FechaEntry();
					entry.setXml(fecha);
					entry.y=posy;
					posy+=entry.ALTURA;
					holder.addChild(entry);
				} // for cada bloque
			// fin parse fechas

			// update scroll pane
			var p:ScrollPane=(this.parent.parent as ScrollPane);
			if (p!=null) p.update();
		}
		
		// -----------------------------------------------------
		
		public function addFecha(e:Event=null) {
			trace("ADD Fecha");
			var b:XML=<fecha/>;
			var d:Date=new Date();
			b.@fecha=pad(d.month+1)+pad(d.date);
			b.@plan=0;
			b.@titulo="-- NUEVO --";
			docFechas.appendChild(b);
			//trace(docFechas.toXMLString());
			
			if (docFechas.children().length()>1)
				ordenarFechas(b);
			else saveDoc();
		}
		
		public function deleteFecha(b:XML) {
			trace("DELETE: "+b.@fecha);
			var index:Number=b.childIndex();
			var p:XML=b.parent();
			var children:XMLList=p.children();
			delete children[index];
			saveDoc();
		}
		
		public function deleteFechas(e:Event=null) {
			trace("DELETE Bloques");
			docFechas.setChildren(new XMLList());
			trace(docFechas.toXMLString());
			saveDoc();
		}
		
		public function ordenarFechas(b:XML) {
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
					if (Number(siguiente.@fecha)>Number(b.@fecha)) {
						p.insertChildBefore(siguiente,b);
						trace("insertado antes de: "+siguiente.@fecha);
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
		
		private function pad(n:Number, z:Number=2):String {
			var r:String=n.toString();
			while (r.length<z) r="0"+r;
			return r;
		}
	}
	
}
