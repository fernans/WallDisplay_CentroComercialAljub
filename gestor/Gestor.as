package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	
	public class Gestor extends MovieClip {
		
		public var pArchivos:panelArchivos;
		public var pHorarios:panelHorarios;
		public var pFechas:panelFechas;
		
		public const DIR_MEDIA:String="../media";
		public const DOC_XML:String="../pantalla.xml";
		
		public function Gestor() {
			// constructor code
			addEventListener(Event.ADDED_TO_STAGE, init);
			stop();
		}
		
		public function init(e:Event) {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			bArchivos.addEventListener(MouseEvent.CLICK, goArchivos);
			bHorarios.addEventListener(MouseEvent.CLICK, goHorarios);
			bFechas.addEventListener(MouseEvent.CLICK, goFechas);
			pArchivos=((spArchivos as ScrollPane).content as panelArchivos);
			pHorarios=((spHorarios as ScrollPane).content as panelHorarios);
			pFechas=((spFechas as ScrollPane).content as panelFechas);
			
			goHorarios();
		}

		//-----------------------------------------------------------
		
		private function goArchivos(e:MouseEvent=null) {
			spHorarios.visible=cartelHorarios.visible=bHorarios.toggle=bHorarios.selected=false;
			spFechas.visible=cartelFechas.visible=bFechas.toggle=bFechas.selected=false;
			spArchivos.visible=cartelArchivos.visible=bArchivos.toggle=bArchivos.selected=true;
			pArchivos.init();
		}
		private function goHorarios(e:MouseEvent=null) {
			spArchivos.visible=cartelArchivos.visible=bArchivos.toggle=bArchivos.selected=false;
			spFechas.visible=cartelFechas.visible=bFechas.toggle=bFechas.selected=false;
			spHorarios.visible=cartelHorarios.visible=bHorarios.toggle=bHorarios.selected=true;
			pHorarios.init();
		}
		private function goFechas(e:MouseEvent=null) {
			spArchivos.visible=cartelArchivos.visible=bArchivos.toggle=bArchivos.selected=false;
			spHorarios.visible=cartelHorarios.visible=bHorarios.toggle=bHorarios.selected=false;
			spFechas.visible=cartelFechas.visible=bFechas.toggle=bFechas.selected=true;
			pFechas.init();
		}

		//-----------------------------------------------------------
		
		public function openAlert(mensaje:String="", showOk:Boolean=false) {
			alertBox.open(mensaje,showOk);
		}
		public function closeAlert() {
			alertBox.close();
		}
		
		//-----------------------------------------------------------
		
		public function isUsed(s:String) {
			var list:XMLList=pHorarios.doc.bloque.content.(@url==(pHorarios.DIR_MEDIA+"/"+s));
			trace("archivo usado en: "+list.length()+" contenidos");
			return (list.length()>0);
		}
		
	}
	
}
