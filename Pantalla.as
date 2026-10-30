package  {
	
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.ui.Mouse;
	import flash.system.Capabilities;
	import flash.display.Loader;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import com.greensock.TweenNano;
	import flash.net.URLRequest;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.events.NetStatusEvent;
	import flash.events.AsyncErrorEvent;
	import flash.display.Bitmap;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;

	// arduino
	import net.eriksjodin.arduino.Arduino;
	import net.eriksjodin.arduino.ArduinoWithServo;
	import net.eriksjodin.arduino.events.ArduinoEvent;
	import net.eriksjodin.arduino.events.ArduinoSysExEvent;
	import flash.net.SharedObject;
	import flash.display.StageAlign;
	
	
	
	public class Pantalla extends MovieClip {
		
		private const RELOADTIME:Number=10;
		private const REFRESHTIME:Number=2;
		private const DEFAULTTIME:Number=5;
		private const ARDUINO_REFRESH:Number=20; // 50 fps
		private const ARDUINO_PIN:Number=0; // Analog 0 IN
		
		private var _stageWidth:Number=768; // 720;
		private var _stageHeight:Number=384; // 320;
		
		// lista
		private var contentList:Array=new Array();
		private var lastContent:String="";
		private var lastContentIndex:Number=-1;
		private var lastContentTime:Number=0;
		private var contentRandom:Boolean=true;
		
		// imagenes
		private var holder:Loader=new Loader();
		// videos
		private var video:Video=null;
		private var ns:NetStream=null;
		private var nss:NetStream=null; // netstream video del sensor
		
		// arduino
		private var arduino:Arduino;
		private var arduinoTimer:Timer;
		private var arduinoLaunched:Boolean=false;
		private var arduinoLevel:Number=256;
		private var arduinoValue:Number=0;
		private const arduinoSmooth:Number=0.75;
		private var arduinoCalib:MovieClip;
		private var arduinoBarra:Barra;
		private var arduinoIndicador:Indicador;
		private const videoSensor:String="sensor.mov";
		
		private var so:SharedObject;
		
		public function Pantalla() {
			// constructor code
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//this._stageWidth=stage.stageWidth;
			//this._stageHeight=stage.stageHeight;
			
			if (!Capabilities.isDebugger) {
				Mouse.hide();
				stage.displayState=StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
			//stage.scaleMode=StageScaleMode.NO_BORDER;
			stage.scaleMode=StageScaleMode.NO_SCALE;
			stage.align=flash.display.StageAlign.TOP_LEFT;
			
			// imagenes
			holder.contentLoaderInfo.addEventListener(Event.COMPLETE, ImageLoaded);
            holder.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ImageError);
			this.addChild(holder);
			holder.x=0;
			holder.y=0;
			holder.visible=false;
			
			// videos
			var nc:NetConnection=new NetConnection();
			nc.connect(null); // local
			ns=new NetStream(nc);
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			ns.client=this;
			ns.bufferTime=10;
			// sensor
			nss=new NetStream(nc);
			nss.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
			nss.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			nss.client=this;
			nss.bufferTime=10;
			// video
			video=new Video(_stageWidth,_stageHeight);
			video.attachNetStream(ns);
			this.addChild(video);
			video.x=0;
			video.y=0;
			video.visible=false;
			
			// lanzar arduino (tras esperar un poco a serproxy)
			TweenNano.delayedCall(1,initArduino);
			
			// lista
			recargarLista();
			
			// iniciar contenido
			lanzarContenido();
		}
		
		// ---------------------------------------------------------------------------------- LISTA
		private function recargarLista() {
			trace(" ");
			trace("RECARGANDO LISTA");
			var contentFile:File=File.applicationDirectory.resolvePath("pantalla.xml");
			var fs:FileStream=new FileStream();
			var conf:XML;
			var plan:XML=null;
			var plannum:Number=NaN;
			var docFechas:XML;
			var bloque:XML=null;
			if (contentFile.exists) {
				trace("  READING CONFIG FILE FROM: "+contentFile.nativePath);
				fs.open(contentFile,FileMode.READ);
				conf=XML(fs.readUTFBytes(fs.bytesAvailable));
				fs.close();
				// buscar plan
					// fecha actual
					var hoy:Date=new Date();
					var hoynum:String=pad(hoy.month+1)+pad(hoy.date);
					// buscar en fechas especiales
					docFechas=null;
					docFechas=conf.fechas[0]; // solo tomar el 1er bloque fechas (si es que hay mas, que no deberia)
					if (docFechas!=null) {
						for (var b:int=0;b<docFechas.fecha.length() && plan==null;b++) {
							if (Number(docFechas.fecha[b].@fecha)==Number(hoynum)) {
								// fecha especial encontrada
								trace("encontrada fecha especial:");
								plannum=docFechas.fecha[b].@plan;
							}
						}
					}
					if (isNaN(plannum)) { // si no se ha encontrado en fechas especiales
						docFechas=null;
						docFechas=conf.dias[0]; // solo tomar el 1er bloque dias (si es que hay mas, que no deberia)
						if (docFechas!=null) {
							switch(hoy.day) {
								case 1: //lunes
									plannum=docFechas.lunes[0].@plan;
								break;
								case 2: //martes
									plannum=docFechas.martes[0].@plan;
								break;
								case 3: //miercoles
									plannum=docFechas.miercoles[0].@plan;
								break;
								case 4: //jueves
									plannum=docFechas.jueves[0].@plan;
								break;
								case 5: //viernes
									plannum=docFechas.viernes[0].@plan;
								break;
								case 6: //sabado
									plannum=docFechas.sabado[0].@plan;
								break;
								case 0: //domingo
									plannum=docFechas.domingo[0].@plan;
								break;
								default: break;
							} // switch dia de la semana
							if (!isNaN(plannum)) trace("asignado por dia de la semana ("+hoy.day+")");
						} // bloque dias de la semana
					} // sin plan aun
				
				if (isNaN(plannum)) {
					trace("PLAN POR DEFECTO");
					plan=conf.plan[0]; // sin plan "finalmente", utilizar el primero
				} else {
					trace("PLAN ENCONTRADO: "+plannum);
					plan=conf.plan[plannum];
				}
				
				// buscar franja horaria
				var currentTime:Date=new Date();
				var horaActual:Number=(currentTime.hours*100)+currentTime.minutes;
				trace("  horaActual: "+horaActual);
				for (var j:int=0;j<plan.bloque.length();j++) {
					if (Number(plan.bloque[j].@hora)<horaActual || bloque==null) bloque=plan.bloque[j];
				}
				trace("  Bloque actual: "+bloque.@hora);
				// cargar contenidos del bloque en la lista
				contentList=new Array();
				for (var c:int=0;c<bloque.content.length();c++) {
					if (bloque.content[c].@url!=null) contentList.push({url:bloque.content[c].@url,time:bloque.content[c].@time});
				}
				contentRandom=true; // por defecto
				if (bloque.@random!=null) contentRandom=(String(bloque.@random).toLocaleLowerCase()=="true");
				
				trace("  Lista actual: (random="+contentRandom+")");
				for (var i:int=0;i<contentList.length;i++) {
					var ob:Object=contentList[i];
					trace("    "+ob.url+"  ("+ob.time+")");
				}
			} else trace("  ERR: file doesn exist");
			TweenNano.delayedCall(RELOADTIME,recargarLista);
		}
		
		private function pad(n:Number, z:Number=2):String {
			var r:String=n.toString();
			while (r.length<z) r="0"+r;
			return r;
		}
		
		// ------------------------------------------------------------------------ LANZAR CONTENIDO
		private function lanzarContenido() {
			trace(" ");
			trace("LANZANDO CONTENIDO");
			if (contentList.length>0) {
				var o:Object=null;
				var r:Number;
				if (!arduinoLaunched) { // si no volvemos despues de la interrupcion de arduino
					if (contentRandom) { // elegir random (sin repetir)
						lastContentIndex=-1;
						do {
							// seleccionar contenido
							r=Math.floor(Math.random()*contentList.length);
							o=contentList[r];
						} while(o.url==lastContent && contentList.length>1)
					} else { // elegir siguiente
						lastContentIndex++;
						if (lastContentIndex>(contentList.length-1)) lastContentIndex=0;
						r=lastContentIndex;
						o=contentList[r];
					}
				} else {
					// si volvemos de interrupcion, repetir/continuar con el ultimo que se lanzo
					o=new Object();
					o.url=lastContent;
					o.time=lastContentTime;
				} 
				trace("  seleccionado: "+r);
				if (o!=null) {
					trace("  content: "+o.url+"  ("+o.time+")");
					lastContent=o.url;
					lastContentTime=o.time;
					// lanzando contenido
					video.visible=holder.visible=false;
					var tipo:String=getExtension(lastContent);
					switch (tipo.toLocaleLowerCase()) {
						case "jpg":
						case "png":
							holder.load(new URLRequest(lastContent));
							holder.visible=true;
							var tiempo:Number=((o.time!=null)?o.time:DEFAULTTIME);
							TweenNano.delayedCall(tiempo,lanzarContenido);
						break;
						// -------------------------------------------------
						case "flv":
						case "mov":
							video.visible=true;
							video.attachNetStream(ns);
							if (arduinoLaunched) {
								// despues de interrupcion, continuar por donde ibamos
								ns.resume();
							} else {
								// normal - desde el principio)
								ns.play(lastContent);
							}
						break;
						// -------------------------------------------------
						default:
							trace("  content type no admitido");
							if (contentList.length>1) {
								trace("    elegir nuevo contenido...");
								lanzarContenido();
							} else {
								trace("    retrasando lanzamiento");
								TweenNano.delayedCall(REFRESHTIME,lanzarContenido);
							}
						break;
					}
				}
			} else {
				trace("  Lista vacia : retrasando lanzamiento");
				TweenNano.delayedCall(REFRESHTIME,lanzarContenido);
			}
			arduinoLaunched=false;
		}
		
		// ---------------------------------------------------------------------------------- TOOLS
		private function getExtension($url:String):String
		{
			var extension:String = $url.substring($url.lastIndexOf(".")+1, $url.length);
			return extension;
		}
		
		// ---------------------------------------------------------------------------------- IMAGENES
		private function ImageLoaded(e:Event) {
			trace("image loaded");
			holder.width=_stageWidth;
			holder.height=_stageHeight;
			var b:Bitmap=(holder.content as Bitmap);
			if (b!=null) b.smoothing=true;
		}
		private function ImageError(e:Event) {
			trace("  ERR: image not loaded... inmediate new content loading");
			TweenNano.killTweensOf(lanzarContenido);
			lanzarContenido();
		}
		
		// ---------------------------------------------------------------------------------- ARDUINO
		function initArduino() {
			// valores de calibracion
			so=SharedObject.getLocal("pantalla","/");
			if (so.data.level==undefined) {
				so.data.level=arduinoLevel;
				so.flush();
			}
			arduinoLevel=so.data.level;
			
			// arduino
			arduino = new Arduino("127.0.0.1", 5331);  // son los "defaults"
			arduino.addEventListener(Event.CONNECT,onSocketConnect); // conectar al puerto
			arduino.addEventListener(IOErrorEvent.IO_ERROR,errorHandler); // error (no serproxy?)
			//arduino.addEventListener(flash.events.ErrorEvent.ERROR, errorHandler);
			arduino.addEventListener(ArduinoEvent.FIRMWARE_VERSION, onReceiveFirmwareVersion); // recibido comunicacion con arduino
		
			arduinoCalib=new MovieClip();
			addChild(arduinoCalib);
			 arduinoBarra=new Barra();
			 arduinoCalib.addChild(arduinoBarra);
			 arduinoIndicador=new Indicador();
			 arduinoCalib.addChild(arduinoIndicador);
			arduinoCalib.visible=false;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyb);
		}
		
		
		// triggered when there is an IO Error
		function errorHandler(errorEvent:IOErrorEvent):void 
		{  
			trace("- "+errorEvent.text);
			trace("- Did you start the Serproxy program ?");
		}
		
		// triggered when a serial socket connection has been established
		function onSocketConnect(e:Object):void 
		{ 
			trace("- Connection with Serproxy established. Wait one moment.");
			arduino.requestFirmwareVersion(); // request the firmware version
		}
		
		// received Firmata version - all ready
		function onReceiveFirmwareVersion(e:ArduinoEvent):void {
			 trace("- Connection with Arduino - Firmata version: " + String(e.value)); 
			 trace("- Set default pin configuration.");
			 // configurar arduino (pines de entrada)
			 arduino.setAnalogPinReporting(ARDUINO_PIN, Arduino.ON);
			 
			 trace("- Start arduino timer.");
			 arduinoTimer = new Timer(ARDUINO_REFRESH);
			 arduinoTimer.addEventListener(TimerEvent.TIMER, onArduinoTick);
			 arduinoTimer.start();
		}
		
		// read arduino values
		public function onArduinoTick(e:Event) {
			var value:Number=arduino.getAnalogData(ARDUINO_PIN);
			//trace("Arduino value: "+value);
			arduinoValue=(arduinoSmooth*arduinoValue)+((1-arduinoSmooth)*value);
			arduinoBarra.width=arduinoValue;
			arduinoIndicador.x=this.arduinoLevel;
			
			if (!this.arduinoLaunched) {
				// check to launch
				if (arduinoValue>arduinoLevel) {
					arduinoTrigger();
				}
			}
		}
		
		public function arduinoTrigger() {
			trace("launch: "+this.videoSensor);
			TweenNano.killTweensOf(lanzarContenido);
			ns.pause();
			nss.play(this.videoSensor);
			video.attachNetStream(nss);
			video.visible=true;
			holder.visible=false;
			arduinoLaunched=true;
		}
		
		// ---------------------------------------------------------------------------------- KEYB
		public function keyb(e:KeyboardEvent) {
			if (e.keyCode==Keyboard.SPACE) {
				arduinoCalib.visible=!arduinoCalib.visible;
			}
			if (arduinoCalib.visible) {
				if (e.keyCode==Keyboard.ENTER) {
					arduinoTrigger();
				}
				if (e.keyCode==Keyboard.RIGHT) {
					if (this.arduinoLevel<1023) this.arduinoLevel++;
					so.data.level=arduinoLevel;
					so.flush();
				}
				if (e.keyCode==Keyboard.LEFT) {
					if (this.arduinoLevel>0) this.arduinoLevel--;
					so.data.level=arduinoLevel;
					so.flush();
				}
				arduinoIndicador.x=this.arduinoLevel;
			}
		}
		
		// ---------------------------------------------------------------------------------- VIDEOS
			// ================================================= METADATAS ===============================
		public function onXMPData(infoObject:Object):void {}
		public function asyncErrorHandler(event:AsyncErrorEvent):void {
			trace("asyncErrorHandler: "+event.text);  // this will handle any errors with video playback  
		}
		public function onMetaData(newMeta:Object):void {  
			//trace("Metadata: duration=" + newMeta.duration + " width=" + newMeta.width + " height=" + newMeta.height + " framerate=" + newMeta.framerate);  // traces what it says  
			//duration = newMeta.duration;  // set the duration variable to the newMeta's duration 
			//if (this.activeVideo1) {
			//	TweenNano.to(holder2,currentEstado.fadeTime,{delay:0.2,alpha:0,onUpdate:fadeAudio});
			//} else {
			//	TweenNano.to(holder2,currentEstado.fadeTime,{delay:0.2,alpha:1,onUpdate:fadeAudio});
			//}
		}
		public function onPlayStatus(status:Object):void {}
		function netStatus(event:NetStatusEvent):void  { 
			//trace(event.info.code);  // this will handle any events that are fired when the video is playing back  
			switch(event.info.code)  //  switch statement to handle the various events with the NetConnection  
			{  
				case "NetStream.Play.StreamNotFound": //error if stream file not found in location specified
					trace("  ERR: Stream not found... inmediate new content loading");
					lanzarContenido();
				break;
				/*/
				case "NetStream.Buffer.Full":  //  when our buffer is full fire the code below  
					if (this.activeVideo1) {
						TweenNano.to(holder2,currentEstado.fadeTime,{delay:0,alpha:0,onUpdate:fadeAudio});
					} else {
						TweenNano.to(holder2,currentEstado.fadeTime,{delay:0,alpha:1,onUpdate:fadeAudio});
					}
				break;  
				/*
				case "NetStream.Buffer.Empty":  //  when our buffer is empty fire the code below  
					ns.bufferTime = 10;  // set buffer time to 10 seconds  
					Tweener.addTween(videoPreloader, {alpha:1, time:.3});  // tween videoPreloaders alpha to 1  
				break;  
				/*
				case "NetStream.Play.Start":  //  when our video starts playing we fire the code below  
					if (this.activeVideo1) {
						TweenNano.to(holder2,currentEstado.fadeTime,{delay:0,alpha:0,onUpdate:fadeAudio});
					} else {
						TweenNano.to(holder2,currentEstado.fadeTime,{delay:0,alpha:1,onUpdate:fadeAudio});
					}
				break; 
				/*
				case "NetStream.Seek.Notify":  // when you seek with the scrubber it sends a notify signal of the time  
					ns.bufferTime = 10;  // set the buffer time to 10 seconds  
					Tweener.addTween(videoPreloader, {alpha:1, time:.3});  //  tween videoPreloaders alpha to 1  
				break;  
				case "NetStream.Seek.InvalidTime":  // when you release the scrubber ahead of the video that has been loaded, you get this error.  it will jump you back to the last frame that has been loaded  
					ns.bufferTime = 10;  // set the buffer time to 10 seconds  
					Tweener.addTween(videoPreloader, {alpha:1, time:.3});  //  tween videoPreloaders alpha to 1  
				break;  
				case "NetStream.Buffer.Flush":
					if (tns==ns1) this.flushed1=true;
					if (tns==ns2) this.flushed2=true;
				break;
				//*/
				case "NetStream.Play.Stop":  // when you reach the end of the video  
					//Tweener.addTween(videoPreloader, {alpha:0, time:.3});  //  tween videoPreloaders alpha to 0  
					lanzarContenido();
					/*
					var ns:NetStream=(event.target as NetStream);
					//if (ns!=null) {ns.pause();ns.seek(0);} // pause to first frame
					if (ns!=null) {
							if ((this.activeVideo1 && ns==ns1) || (!this.activeVideo1 && ns==ns2)) { // ignorar final del video no activo
								//launch events
								var cs:EstadoVideo=this.currentEstado;
								//after first
								if (this.firstVideo) {
									launchAfterFirstEvent();
								}
								if (!currentEstado.randomMode) { // not on random-mode
									//after last
									if (currentVideoIndex==currentEstado.videoList.length-1) {
										launchAfterLastEvent();
									}
								}
								if (this.currentEstado==cs) { // if still on the same videoEstado (after events)
									// select & launch next video
									launchVideo(ns);
								}
							}
							// rewind and loop
							//ns.pause();  // pause the video
							//ns.seek(0);  // seek the video to the first frame
							//ns.resume();
					}
					//*/
					
				break;  
			}  
		} 
		// ================================================= METADATAS ===============================


		// ---------------------------------------------------------------------------------- 
		
	}
	
}
