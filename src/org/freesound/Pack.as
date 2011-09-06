package org.freesound
{
	import com.adobe.serialization.json.JSONDecoder;
	import flash.events.EventDispatcher;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class Pack extends EventDispatcher
	{
		private var apiKey:String = "";
		private var http:HTTPService = new HTTPService();
		public var packLoaded:Boolean = false;
		
		// Pack properties
		public var info:Object = new Object();
		
		public function Pack(key:String)
		{
			this.apiKey = key;
			this.http.addEventListener( ResultEvent.RESULT, resultHandler );
			this.http.addEventListener( FaultEvent.FAULT, faultHandler );
		}
		
		public function loadInfo(info:Object):void
		{
			this.info = info;
			this.packLoaded = true;
		}
		
		public function getPackFromId(id:int):void
		{
			this.http.url = "http://www..freesound.org/api/packs/" + id.toString();
			this.http.resultFormat = "text";
			
			var params:Object = {};
			params.api_key = this.apiKey;
			
			this.http.send(params);	
		}
		
		// Result handler
		private function resultHandler(event:ResultEvent):void
		{
			
			var data:String = event.result.toString();
			var jd:JSONDecoder = new JSONDecoder(data,true);		
			this.loadInfo(jd.getValue());
			
			// Notify client that info is available
			this.dispatchEvent(new ResultEvent("GotPackInfo"));	
		}
		
		// Fault handler
		private function faultHandler(event:FaultEvent):void
		{
			this.dispatchEvent(event);
		}
	}
}