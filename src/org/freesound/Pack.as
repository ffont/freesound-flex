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
		public var name:String = "";
		public var ref:String = "";
		public var url:String = "";
		public var id:int = -1;
		public var sounds:String = "";
		public var descriptrion:String = "";
		public var created:String = "";
		public var num_downloads:String = "";
		public var user_name:String = "";
		public var user:Object = {username:"",url:"",ref:""};
		
		
		public function Pack(key:String)
		{
			this.apiKey = key;
			this.http.addEventListener( ResultEvent.RESULT, resultHandler );
			this.http.addEventListener( FaultEvent.FAULT, faultHandler );
		}
		
		public function loadInfo(name:String, 
								 ref:String, 
								 url:String, 
								 sounds:String, 
								 description:String, 
								 created:String, 
								 num_downloads:String, 
								 user:Object
								):void
		{
			this.name = name;
			this.ref = ref;
			this.url = url;
			this.id = (int)(this.url.slice(this.url.lastIndexOf("/",this.url.length - 2) + 1,this.url.length - 1));
			this.sounds = sounds;
			this.descriptrion = description;
			this.created = created;
			this.num_downloads = num_downloads;
			this.user = user;
			
			this.packLoaded = true;
		}
		
		public function getPackFromId(id:int):void
		{
			this.http.url = "http://tabasco.upf.edu/api/packs/" + id.toString();
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
			this.loadInfo(	jd.getValue().name,
							jd.getValue().ref,
							jd.getValue().url,
							jd.getValue().sounds,
							jd.getValue().description,
							jd.getValue().created,
							jd.getValue().num_downloads,
							jd.getValue().user
							);
			
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