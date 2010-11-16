package org.freesound
{
	import com.adobe.serialization.json.JSONDecoder;
	import org.freesound.Sound;
	import flash.events.EventDispatcher;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class SoundCollection extends EventDispatcher
	{
		private var apiKey:String = "";
		private var http:HTTPService = new HTTPService();
		public var listLoaded:Boolean = false;
		private var fullResultsMode:Boolean = false;
		
		// Sound list
		public var soundList:Array = new Array();
		public var num_results:int = 0;
		public var num_pages:int = 0;
		public var previous:String = "";
		public var next:String = "";
		
		public var current_page:int = 1;
		
		public function SoundCollection(key:String)
		{
			this.apiKey = key;
			this.http.addEventListener( ResultEvent.RESULT, resultHandler );
			this.http.addEventListener( FaultEvent.FAULT, faultHandler );
		}
		
		public function getSoundsFromRef(ref:String):void
		{
			
			this.http.url = ref;
			this.http.resultFormat = "text";
			
			var params:Object = {};
			params.api_key = this.apiKey;
			
			this.http.send(params);	
		}
		
		public function getSoundsFromUser(name:String):void
		{
			this.getSoundsFromRef("http://tabasco.upf.edu/api/people/" + name + "/sounds");
		}
		
		public function getSoundsFromPackId(id:int):void
		{
			//this.getSoundsFromQuery({f:"pack:" + packname + " username:" + username});
			this.getSoundsFromRef("http://tabasco.upf.edu/api/packs/" + id.toString() + "/sounds");
		}
		
		public function getSoundsFromQuery(params:Object):void
		{
		
			this.http.url = "http://tabasco.upf.edu/api/sounds/search";
			this.http.resultFormat = "text";
			
			params.api_key = this.apiKey;
			
			this.current_page = 1;
			if (params.hasOwnProperty("p")){
				this.current_page = params.p;
			}
						
			this.http.send(params);	
			
		}
		
		public function enableFullResultsMode():void
		{
			this.fullResultsMode = true;	
		}
		
		public function disableFullResultsMode():void
		{
			this.fullResultsMode = false;	
		}
		
		public function nextPage():void
		{
			if (next != null){
				this.getSoundsFromRef(this.next);
				this.current_page = this.current_page + 1;
			}
		}
		
		public function previousPage():void
		{
			if (previous != null){
				this.getSoundsFromRef(this.previous);
				this.current_page = this.current_page - 1;
			}
		}
		
		// Result handler
		private function resultHandler(event:ResultEvent):void
		{
			
			var data:String = event.result.toString();
			var jd:JSONDecoder = new JSONDecoder(data,true);
			
			// Fill data structure
			if (!fullResultsMode){
				this.soundList = new Array();
			}
			
			for (var i:int=0;i<jd.getValue().sounds.length;i++) {
				var s:Sound = new Sound(this.apiKey);
				s.loadInfo(	jd.getValue().sounds[i].id,
							jd.getValue().sounds[i].ref, 
							jd.getValue().sounds[i].url, 
							jd.getValue().sounds[i].preview, 
							jd.getValue().sounds[i].serve, 
							jd.getValue().sounds[i].type, 
							jd.getValue().sounds[i].duration, 
							-1.0, //jd.getValue().sounds[i].samplerate, // null, only aviablable on single-sound request (Sound class)
							jd.getValue().sounds[i].bitdephth, 
							jd.getValue().sounds[i].filesize, 
							jd.getValue().sounds[i].bitrate, 
							jd.getValue().sounds[i].channels, 
							jd.getValue().sounds[i].original_filename, 
							"", //jd.getValue().sounds[i].description, // null, only aviablable on single-sound request (Sound class)
							jd.getValue().sounds[i].tags, 
							"", //jd.getValue().sounds[i].license, // null, only aviablable on single-sound request (Sound class)
							"", //d.getValue().sounds[i].created, // null, only aviablable on single-sound request (Sound class)
							jd.getValue().sounds[i].num_comments, 
							jd.getValue().sounds[i].num_downloads, 
							jd.getValue().sounds[i].num_ratings, 
							-1.0, //jd.getValue().sounds[i].avg_rating, // null, only aviablable on single-sound request (Sound class)
							jd.getValue().sounds[i].pack, 
							jd.getValue().sounds[i].user, 
							jd.getValue().sounds[i].spectral_m, 
							jd.getValue().sounds[i].spectral_l, 
							jd.getValue().sounds[i].waveform_m, 
							jd.getValue().sounds[i].waveform_l 
				);
				this.soundList.push(s);
			}
			
			this.num_results = jd.getValue().num_results; // Only useful in queries (not from references)
			this.num_pages = jd.getValue().num_pages; // Only useful in queries (not from references)
			this.previous = jd.getValue().previous;
			this.next = jd.getValue().next;
			
			if (!fullResultsMode){
				// Notify client that info is available
				this.listLoaded = true;
				this.dispatchEvent(new ResultEvent("GotSoundCollection"));
			}else{
				if (this.next != null){
					// If still not in last page, advance one
					this.nextPage();
					if (this.num_pages != 0){
						trace("Gathering information... (" + ((this.current_page/this.num_pages)*100).toPrecision(3) + "%)");
					}else{
						trace("Gathering information...");
					}
				}else{
					// Notify client that info is available
					this.listLoaded = true;
					this.dispatchEvent(new ResultEvent("GotSoundCollection"));
					
				}
			}	
		}
		
		// Fault handler
		private function faultHandler(event:FaultEvent):void
		{
			this.dispatchEvent(event);
		}
		
	}
}