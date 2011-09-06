package org.freesound
{
	import com.adobe.serialization.json.JSONDecoder;
	import org.freesound.PackCollection;
	import flash.events.EventDispatcher;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class User extends EventDispatcher
	{
		private var apiKey:String = "";
		private var http:HTTPService = new HTTPService();
		private var userLoaded:Boolean = false;
		
		// User properties
		public var info:Object = new Object();
		
		private var packCollection:PackCollection;
		
		public function User(key:String)
		{
			this.apiKey = key;
			this.http.addEventListener( ResultEvent.RESULT, userInfoHandler );
			this.http.addEventListener( FaultEvent.FAULT, faultHandler );
			
			this.packCollection = new PackCollection(this.apiKey)
		}
		
		public function getUserFromRef(ref:String):void{
			this.http.url = ref;
			this.http.resultFormat = "text";
			
			var params:Object = {};
			params.api_key = this.apiKey;
			
			this.http.send(params);	
		}
		
		public function getUserFromName(name:String):void{
			this.getUserFromRef("http://www..freesound.org/api/people/" + name);		
		}
				
		// Result handler
		private function userInfoHandler(event:ResultEvent):void
		{

			var data:String = event.result.toString();
			var jd:JSONDecoder = new JSONDecoder(data,true);
			
			// Fill data structure			
			this.info = jd.getValue();
			
			// Ask for pack information
			this.packCollection.getPacksFromUser(this.info.username);
			this.packCollection.addEventListener("GotUserPacks", packInfoHandler);
			
		}
		
		private function packInfoHandler(event:ResultEvent):void
		{
			// Notify client that info is available
			this.userLoaded = true;
			this.dispatchEvent(new ResultEvent("GotUserInfo"));
		}
		
		public function getPackList():Array{
			if (this.packCollection.listLoaded){
				return this.packCollection.packList;
			}else{
				return null;
			}
		}

		// Fault handler
		private function faultHandler(event:FaultEvent):void
		{
			this.dispatchEvent(event);
		}
	}
}