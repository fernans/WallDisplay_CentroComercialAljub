package  {
	
	import flash.display.MovieClip;
	import flash.filesystem.File;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class HorarioEntry extends MovieClip {
		
		private var item:XML;
		private var file:File;
		private var time:Number;
		
		public var DIR_MEDIA:String=".";
		
		public function HorarioEntry(dir:String=".") {
			// constructor code
			DIR_MEDIA=dir;
		}
		
		public function getFile():File {
			return file;
		}
		public function setFile(f:File):void {
			file=f;
			//trace(file.nativePath);
			timeLabel.visible=timeSegs.visible=false;
			if (file.exists) {
				title.text=file.name;
				if (file.type==".jpg" || file.type==".png") {
					fileIcon.gotoAndStop(2);
					timeLabel.visible=timeSegs.visible=true;
				} else if (file.type==".mov" || file.type==".flv") {
					fileIcon.gotoAndStop(3);
				} else fileIcon.gotoAndStop(0); // unknown;
			} else {
				// file doesnt exist
				title.text="-- no file reference --";
				bDelete.visible=false;
				fileIcon.gotoAndStop(0); // unknown;
			}
			bDelete.addEventListener(MouseEvent.CLICK, bDeleteClick);
			bUp.addEventListener(MouseEvent.CLICK, bUpClick);
			bDown.addEventListener(MouseEvent.CLICK, bDownClick);
			timeLabel.addEventListener(Event.CHANGE, timeLabelEdit);
			timeLabel.addEventListener(FocusEvent.FOCUS_IN, timeLabelOn);
			timeLabel.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
			timeLabel.restrict="0-9";
			fileIcon.addEventListener(MouseEvent.CLICK, bUrlClick);
			title.addEventListener(MouseEvent.CLICK, bUrlClick);
		}
		
		public function getTime():Number {
			return time;
		}
		public function setTime(t:Number) {
			time=t;
			timeLabel.text=String(time);
		}
		
		public function setXml(i:XML) {
			item=i;
			//setFile(File.applicationDirectory.resolvePath(DIR_MEDIA).resolvePath(item.@url));
			setFile((new File(File.applicationDirectory.nativePath)).resolvePath("..").resolvePath(item.@url));
			//trace(DIR_MEDIA);
			//trace(item.@url);
			//trace((new File(File.applicationDirectory.nativePath)).resolvePath(DIR_MEDIA).nativePath);
			//trace((new File(File.applicationDirectory.nativePath)).resolvePath(DIR_MEDIA).resolvePath(item.@url).nativePath);
			//trace("---");
			setTime(item.@time);
		}
		public function getXml():XML {
			return item;
		}
		
		public function bDeleteClick(e:Event=null) {
			if (parent is panelHorarios) {
				(parent as panelHorarios).deleteItem(item);
			}
		}
		public function bUpClick(e:Event=null) {
			if (parent is panelHorarios) {
				(parent as panelHorarios).upItem(item);
			}
		}
		public function bDownClick(e:Event=null) {
			if (parent is panelHorarios) {
				(parent as panelHorarios).downItem(item);
			}
		}
		
		public function timeLabelEdit(e:Event=null) {
			trace(timeLabel.text);
			time=Number(timeLabel.text);
			item.@time=time;
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
			if (parent is panelHorarios) {
				(parent as panelHorarios).saveDoc();
			}
		}
		public function outfocus(e:Event) {
			if (e.target!=timeLabel) timeLabelOff(e);
		}
		public function onKey(e:KeyboardEvent) {
			if (e.keyCode==Keyboard.ENTER) timeLabelOff(e);
		}
		
		public function bUrlClick(e:Event=null) {
			if (parent is panelHorarios) {
				(parent as panelHorarios).changeUrl(item,(fileIcon.currentFrame==3));
			}
		}
		
	}
	
}
