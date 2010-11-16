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
		public var id:int = -1;
		public var ref:String = "";
		public var url:String = "";
		public var preview:String = "";
		public var serve:String = "";
		public var type:String = "";
		public var duration:Number = -1.0;
		public var samplerate:Number = -1.0;
		public var bitdepth:int = -1;
		public var filesize:int = -1;
		public var bitrate:int = -1;
		public var channels:int = -1;
		public var original_filename:String = "";
		public var description:String = "";
		public var tags:Array = new Array();
		public var license:String = "";
		public var created:String = "";
		public var num_comments:int = -1;
		public var num_downloads:int = -1;
		public var num_ratings:int = -1;
		public var avg_rating:Number = -1.0;
		public var pack:String = "";
		public var user:Object = {username:"",url:"",ref:""};
		public var spectral_m:String = "";
		public var spectral_l:String = "";
		public var waveform_m:String = "";
		public var waveform_l:String = "";
		
		
		public function Sound(key:String)
		{
			this.apiKey = key;
			this.http.addEventListener( ResultEvent.RESULT, resultHandler );
			this.http.addEventListener( FaultEvent.FAULT, faultHandler );
		}
		
		public function loadInfo(id:int,
								 ref:String,
								 url:String,
								 preview:String,
								 serve:String,
								 type:String,
								 duration:Number,
								 samplerate:Number,
								 bitdepth:int,
								 filesize:int,
								 bitrate:int,
								 channels:int,
								 original_filename:String,
								 description:String,
								 tags:Array,
								 license:String,
								 created:String,
								 num_comments:int,
								 num_downloads:int,
								 num_ratings:int,
								 avg_rating:Number,
								 pack:String,
								 user:Object,
								 spectral_m:String,
								 spectral_l:String,
								 waveform_m:String,
								 waveform_l:String
								):void
		{
			
			this.id = id;
			this.ref = ref;
			this.url = url;
			this.preview = preview;
			this.serve = serve;
			this.type = type;
			this.duration = duration;
			this.samplerate = samplerate;
			this.bitdepth = bitdepth;
			this.filesize = filesize;
			this.bitrate = bitrate;
			this.channels = channels;
			this.original_filename = original_filename;
			this.description = description;
			this.tags = tags;
			this.license = license;
			this.created = created;
			this.num_comments = num_comments;
			this.num_downloads = num_downloads;
			this.num_ratings = num_ratings;
			this.avg_rating = avg_rating;
			this.pack = pack;
			
			if (user != null){ // in case user information is not delivered in the data
				this.user = user;
			}else{
				user = {username:"",url:"",ref:""};
			}
			
			this.spectral_m = spectral_m;
			this.spectral_l = spectral_l;
			this.waveform_m = waveform_m;
			this.waveform_l = waveform_l;
			
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
			this.loadInfo(	jd.getValue().id,
							jd.getValue().ref, 
							jd.getValue().url, 
							jd.getValue().preview, 
							jd.getValue().serve, 
							jd.getValue().type, 
							jd.getValue().duration, 
							jd.getValue().samplerate, 
							jd.getValue().bitdephth, 
							jd.getValue().filesize, 
							jd.getValue().bitrate, 
							jd.getValue().channels, 
							jd.getValue().original_filename, 
							jd.getValue().description, 
							jd.getValue().tags, 
							jd.getValue().license, 
							jd.getValue().created, 
							jd.getValue().num_comments, 
							jd.getValue().num_downloads, 
							jd.getValue().num_ratings, 
							jd.getValue().avg_rating, 
							jd.getValue().pack, 
							jd.getValue().user, 
							jd.getValue().spectral_m, 
							jd.getValue().spectral_l, 
							jd.getValue().waveform_m, 
							jd.getValue().waveform_l 
			);
				
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