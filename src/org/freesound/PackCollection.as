package org.freesound
{
	import com.adobe.serialization.json.JSONDecoder;
	import org.freesound.Pack;
	import flash.events.EventDispatcher;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class PackCollection extends EventDispatcher
	{
		private var apiKey:String = "";
		private var http:HTTPService = new HTTPService();
		public var listLoaded:Boolean = false;
		
		// Pack list
		public var packList:Array = new Array();
		private var user_name:String = "";
		
		public function PackCollection(key:String)
		{
			this.apiKey = key;
			this.http.addEventListener( ResultEvent.RESULT, resultHandler );
			this.http.addEventListener( FaultEvent.FAULT, faultHandler );
		}
		
		public function getPacksFromRef(ref:String):void
		{
			this.user_name = ref.slice(ref.lastIndexOf("/",ref.length - 7) + 1,ref.length - 6);
	
			this.http.url = ref;
			this.http.resultFormat = "text";
			
			var params:Object = {};
			params.api_key = this.apiKey;
			
			this.http.send(params);	
		}
		
		public function getPacksFromUser(name:String):void
		{
			this.user_name = name;
			this.getPacksFromRef("http://tabasco.upf.edu/api/people/" + name + "/packs");
		}
		
		// Result handler
		private function resultHandler(event:ResultEvent):void
		{
			
			var data:String = event.result.toString();
			var jd:JSONDecoder = new JSONDecoder(data,true);
			
			// Fill data structure		
			this.packList = new Array();
			for (var i:int=0;i<jd.getValue().length;i++) {
				var p:Pack = new Pack(this.apiKey);
				p.loadInfo(	jd.getValue()[i].name,
							jd.getValue()[i].ref,
							jd.getValue()[i].url,
							jd.getValue()[i].sounds,
							jd.getValue()[i].description,
							jd.getValue()[i].created,
							jd.getValue()[i].num_downloads,
							{username:this.user_name,url:"http://tabasco.upf.edu/people/" + this.user_name + "/",ref:"http://tabasco.upf.edu/api/people/" + this.user_name + "/"}
							);
				this.packList.push(p);
			}

			// Notify client that info is available
			this.listLoaded = true;
			this.dispatchEvent(new ResultEvent("GotUserPacks"));
			
		}
		
		// Fault handler
		private function faultHandler(event:FaultEvent):void
		{
			this.dispatchEvent(event);
		}
		
	}
}