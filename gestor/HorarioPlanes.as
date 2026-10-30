package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class HorarioPlanes extends MovieClip {
		
		public const ALTURA:Number=30;
		
		public function HorarioPlanes() {
			// constructor code
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		public function init(e:Event) {
			// events
			bPlan1.addEventListener(MouseEvent.CLICK, select);
			bPlan2.addEventListener(MouseEvent.CLICK, select);
			bPlan3.addEventListener(MouseEvent.CLICK, select);
			bPlan4.addEventListener(MouseEvent.CLICK, select);
			bPlan5.addEventListener(MouseEvent.CLICK, select);
			bPlan6.addEventListener(MouseEvent.CLICK, select);
			bPlan7.addEventListener(MouseEvent.CLICK, select);
			bPlan8.addEventListener(MouseEvent.CLICK, select);
			bPlan9.addEventListener(MouseEvent.CLICK, select);
			bPlan10.addEventListener(MouseEvent.CLICK, select);
			
			bCopiar.addEventListener(MouseEvent.CLICK, copiar);
		}
		
		public function activar(n:Number=0) {
			// desactivar todos, activando solo el indicado
			bPlan1.toggle=bPlan1.selected=(n==0);
			bPlan2.toggle=bPlan2.selected=(n==1);
			bPlan3.toggle=bPlan3.selected=(n==2);
			bPlan4.toggle=bPlan4.selected=(n==3);
			bPlan5.toggle=bPlan5.selected=(n==4);
			bPlan6.toggle=bPlan6.selected=(n==5);
			bPlan7.toggle=bPlan7.selected=(n==6);
			bPlan8.toggle=bPlan8.selected=(n==7);
			bPlan9.toggle=bPlan9.selected=(n==8);
			bPlan10.toggle=bPlan10.selected=(n==9);
		}
		
		public function select(e:Event) {
			var pulsado:Number=Number((e.target as Button).name.substr(5))-1;
			(parent as panelHorarios).plan=pulsado;
			(parent as panelHorarios).parseDoc();
		}
		
		public function copiar(e:Event) {
			var destino:Number=cDestino.selectedItem.data;
			(parent as panelHorarios).copiar(destino);
		}
		
	}
	
}
