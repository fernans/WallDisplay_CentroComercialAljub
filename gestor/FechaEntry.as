package  {
	
	import flash.display.MovieClip;
	import flash.filesystem.File;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class FechaEntry extends MovieClip {
		
		public var ALTURA:Number=43;
		private var entry:XML;
		
		public function FechaEntry() {
			// constructor code
			
			cPlan.addEventListener(Event.CHANGE, planChange);
			//tTitulo.addEventListener(Event.CHANGE, tituloChange);
	
			tFecha.addEventListener(FocusEvent.FOCUS_IN, fechaOn);
			tFecha.addEventListener(KeyboardEvent.KEY_DOWN, fechaKey);
			
			tTitulo.addEventListener(FocusEvent.FOCUS_IN, tituloOn);
			tTitulo.addEventListener(KeyboardEvent.KEY_DOWN, tituloKey);
			
			bDelete.addEventListener(MouseEvent.CLICK, bDeleteClick);
		}
		
		public function setXml(e:XML) {
			entry=e;
			var temp:String=e.@fecha;
			tFecha.text=temp.substr(2,2)+"/"+temp.substr(0,2);
			cPlan.selectedIndex=e.@plan;
			tTitulo.text=e.@titulo;
		}
		
		public function set fecha(f:String) {
			tFecha.text=f;
		}
		public function get fecha():String {
			return tFecha.text;
		}
		
		public function set titulo(t:String) {
			tTitulo.text=t;
		}
		public function get titulo():String {
			return tTitulo.text;
		}
		
		public function set plan(n:Number) {
			cPlan.selectedIndex=n;
		}
		public function get plan():Number {
			return cPlan.selectedItem.data;
		}
		
		// ------------------------------------------------------------
		
		public function planChange(e:Event=null) {
			trace("planChange");
			entry.@plan=plan;
			save();
		}
		public function tituloChange(e:Event=null) {
			trace("tituloChange");
			entry.@titulo=titulo;
			save();
		}
		public function fechaChange(e:Event=null) {
			trace("fechaChange");
			var t:Array=removeSeparators(tFecha.text);
			var dia:String=t[0];
			var mes:String=t[1];
			var dian:Number=Number(dia);
			var mesn:Number=Number(mes);
			if (!isNaN(dian) && !isNaN(mesn)) {
				var f:Date=new Date(0,mesn-1,dian);
				entry.@fecha=pad(f.month+1)+pad(f.date);
				ordenar();
			}
		}
		// ------------------------------------------------------
		public function fechaOn(e:Event=null) {
			tFecha.border=true;
			tFecha.background=true;
			stage.addEventListener(MouseEvent.CLICK, fechaOff);
		}
		public function fechaOff(e:Event) {
			if (!stage) return;
			if (e.target!=tFecha) {
				tFecha.border=false;
				tFecha.background=false;
				stage.removeEventListener(MouseEvent.CLICK, fechaOff);
				fechaChange(e);
			}
		}
		public function fechaKey(e:KeyboardEvent) {
			if (e.keyCode==Keyboard.ENTER) fechaOff(new Event(e.type));
		}
		
		
		public function tituloOn(e:Event=null) {
			tTitulo.border=true;
			tTitulo.background=true;
			stage.addEventListener(MouseEvent.CLICK, tituloOff);
		}
		public function tituloOff(e:Event) {
			if (!stage) return;
			if (e.target!=tTitulo) {
				tTitulo.border=false;
				tTitulo.background=false;
				stage.removeEventListener(MouseEvent.CLICK, tituloOff);
				tituloChange(e);
			}
		}
		public function tituloKey(e:KeyboardEvent) {
			if (e.keyCode==Keyboard.ENTER) tituloOff(new Event(e.type));
		}
		
		// ------------------------------------------------------
		
		public function save() {
			// parent directo es holder
			// parent del holder es el panelFechas
			if (parent!=null && parent.parent is panelFechas) {
				(parent.parent as panelFechas).saveDoc();
			}
		}
		public function ordenar() {
			// parent directo es holder
			// parent del holder es el panelFechas
			if (parent!=null && parent.parent is panelFechas) {
				(parent.parent as panelFechas).ordenarFechas(entry);
			}
		}
		
		public function bDeleteClick(e:Event=null) {
			// parent directo es holder
			// parent del holder es el panelFechas
			if (parent!=null && parent.parent is panelFechas) {
				(parent.parent as panelFechas).deleteFecha(entry);
			}
		}
		
		// ------------------------------------------------------------
		
		public function removeSeparators(t:String):Array {
			var re:RegExp = /[^0-9]/;
			return t.split(re);
		}
		
		private function pad(n:Number, z:Number=2):String {
			var r:String=n.toString();
			while (r.length<z) r="0"+r;
			return r;
		}
		
	}
	
}
