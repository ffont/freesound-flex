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
		public var username:String = "";
		public var first_name:String = "";
		public var last_name:String = "";
		public var url:String = "";
		public var ref:String = "";
		public var sounds:String = "";
		public var packs:String = "";
		public var about:String = "";
		public var home_page:String = "";
		public var signature:String = "";
		public var date_joined:String = "";
		
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
			this.getUserFromRef("http://tabasco.upf.edu/api/people/" + name);		
		}
				
		// Result handler
		private function userInfoHandler(event:ResultEvent):void
		{

			var data:String = event.result.toString();
			var jd:JSONDecoder = new JSONDecoder(data,true);
			
			// Fill data structure			
			this.username = 	jd.getValue().username;
			this.first_name = 	jd.getValue().first_name;
			this.last_name = 	jd.getValue().last_name;
			this.url = 			jd.getValue().url;
			this.ref = 			jd.getValue().ref;
			this.sounds = 		jd.getValue().sounds;
			this.packs = 		jd.getValue().packs;
			this.about = 		jd.getValue().about;
			this.home_page = 	jd.getValue().home_page;
			this.signature = 	jd.getValue().signature;
			this.date_joined = 	jd.getValue().date_joined;
			
			// Ask for pack information
			this.packCollection.getPacksFromUser(this.username);
			this.packCollection.addEventListener("GotUserPacks", packInfoHandler);
			
		}
		
		private function packInfoHandler(event:ResultEvent):void
		{
			// Notify client that info is available
			this.userLoaded = true;
			this.dispatchEvent(new ResultEvent("GotUserInformation"));
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