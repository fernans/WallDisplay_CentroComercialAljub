package  {
	
	import flash.display.MovieClip;
	import flash.filesystem.File;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class BloqueEntry extends MovieClip {
		
		public const ALTURA:Number=40;
		
		private var bloque:XML;
		private var hora:Number;
		private var rand:Boolean=false;
		
		public function BloqueEntry() {
			// constructor code
		}
		
		public function getHora():Number {
			return hora;
		}
		public function setHora(t:Number) {
			hora=t;
			timeLabel.text=String(hora);
		}
		
		public function getRandom():Boolean {
			return rand;
		}
		public function setRandom(r:Boolean) {
			rand=r;
			bRandom.selected=rand;
		}
		
		public function setXml(b:XML) {
			bloque=b;
			setHora(bloque.@hora);
			setRandom(String(bloque.@random).toLocaleLowerCase()=="true");
			
			bDelete.addEventListener(MouseEvent.CLICK, bDeleteClick);
			timeLabel.addEventListener(Event.CHANGE, timeLabelEdit);
			timeLabel.addEventListener(FocusEvent.FOCUS_IN, timeLabelOn);
			timeLabel.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
			timeLabel.restrict="0-9";
			bRandom.addEventListener(Event.CHANGE, bRandomClick);
		}
		public function getXml():XML {
			return bloque;
		}
		
		public function bDeleteClick(e:Event=null) {
			if (parent is panelHorarios) {
				(parent as panelHorarios).deleteBloque(bloque);
			}
		}
		
		public function timeLabelEdit(e:Event=null) {
			trace(timeLabel.text);
			hora=Number(timeLabel.text);
			bloque.@hora=hora;
		}
		public function timeLabelOn(e:Event=null) {
			trace("on");
			timeLabel.border=true;
			timeLabel.background=true;
			stage.addEventListener(MouseEvent.CLICK, outfocus);
		}
		public function timeLabelOff(e:Event=null) {
			trace("off");
			timeLabel.border=false;
			timeLabel.background=false;
			stage.removeEventListener(MouseEvent.CLICK, outfocus);
			// ordenar bloque
			if (parent is panelHorarios) {
				(parent as panelHorarios).ordenarBloque(bloque);
			}
		}
		public function outfocus(e:Event) {
			if (e.target!=timeLabel) timeLabelOff(e);
		}
		public function onKey(e:KeyboardEvent) {
			if (e.keyCode==Keyboard.ENTER) timeLabelOff(e);
		}
		
		public function bRandomClick(e:Event=null) {
			rand=bRandom.selected;
			bloque.@random=rand;
			trace("set random to: "+bloque.@random);
			if (parent is panelHorarios) {
				(parent as panelHorarios).saveDoc();
			}
		}
		
	}
	
}
