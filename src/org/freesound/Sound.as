package org.freesound
{
	import com.adobe.serialization.json.JSONDecoder;
	import flash.events.EventDispatcher;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class Sound extends EventDispatcher
	{
		private var apiKey:String = "";
		private var http:HTTPService = new HTTPService();
		public var soundLoaded:Boolean = false; // Sound information loaded flag (not audio data)
		
		// Sound properties
		public var info:Object = new Object();
		
		public function Sound(key:String)
		{
			this.apiKey = key;
			this.http.addEventListener( ResultEvent.RESULT, resultHandler );
			this.http.addEventListener( FaultEvent.FAULT, faultHandler );
		}
		
		public function loadInfo(info:Object):void
		{
			this.info = info;
			this.soundLoaded = true;
		}
		
		public function getSoundFromRef(ref:String):void
		{
			this.http.url = ref;
			this.http.resultFormat = "text";
			
			var params:Object = {};
			params.api_key = this.apiKey;
			
			this.http.send(params);			
		}
		
		public function getSoundFromId(id:int):void
		{
			this.getSoundFromRef("http://tabasco.upf.edu/api/sounds/" + id.toString());
		}
		
		/*
		public function getSoundFromName(id:int):void
		{
		}
		*/
		
		// Result handler
		private function resultHandler(event:ResultEvent):void
		{
			
			var data:String = event.result.toString();
			var jd:JSONDecoder = new JSONDecoder(data,true);
			this.loadInfo(jd.getValue());
			
			// Notify client that info is available
			this.dispatchEvent(new ResultEvent("GotSoundInfo"));	
		
		}
		
		// Fault handler
		private function faultHandler(event:FaultEvent):void
		{
			this.dispatchEvent(event);
		}
	}
}