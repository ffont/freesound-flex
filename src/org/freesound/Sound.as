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
		public var soundAnalysis:Boolean = false; // Sound analysis loaded flag (not audio data)
		private var currentTypeOfRequestedData = "sound_info"; // This variable is used by the resultHandler in order to know which type of data is being returned (either sund information or sound analysis data)
		
		// Sound properties
		public var info:Object = new Object();
		public var analysis:Object = new Object();
		
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
		
		public function loadAnalysis(analysis:Object):void
		{
			this.analysis = analysis;
			this.soundAnalysis = true;
		}
		
		public function getSoundFromRef(ref:String):void
		{
			this.http.url = ref;
			this.http.resultFormat = "text";
			currentTypeOfRequestedData = "sound_info";
			
			var params:Object = {};
			params.api_key = this.apiKey;
			
			this.http.send(params);			
		}
		
		public function getSoundFromId(id:int):void
		{
			this.getSoundFromRef("http://tabasco.upf.edu/api/sounds/" + id.toString());
		}
		
		public function getSoundAnalysis(filter:String = ""):void
		{
			// If there is no sound loaded we cannot retrieve analysis data
			if (soundLoaded == true){
				this.http.url = "http://tabasco.upf.edu/api/sounds/" + this.info['id'].toString() + "/analysis/" + filter;
				this.http.resultFormat = "text";
				currentTypeOfRequestedData = "sound_analysis";
				
				var params:Object = {};
				params.api_key = this.apiKey;
				
				this.http.send(params);	
			}
		}
		
		
		// Result handler
		private function resultHandler(event:ResultEvent):void
		{
			var data:String = event.result.toString();
			var jd:JSONDecoder = new JSONDecoder(data,true);
			
			if (currentTypeOfRequestedData == "sound_info"){	
				
				this.loadInfo(jd.getValue());
			
				// Notify client that info is available
				this.dispatchEvent(new ResultEvent("GotSoundInfo"));
				
			}else if (currentTypeOfRequestedData == "sound_analysis"){
				this.loadAnalysis(jd.getValue());
				
				// Notify client that analysis is available
				this.dispatchEvent(new ResultEvent("GotSoundAnalysis"));
			}
		
		}
		
		// Fault handler
		private function faultHandler(event:FaultEvent):void
		{
			this.dispatchEvent(event);
		}
	}
}