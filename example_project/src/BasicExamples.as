// Include an actionscript file with the API key
// This file must only contain a variable named "apiKey" like: public static const apiKey:String = "YOUR_KEY_HERE";
include "ApiKey.as";

// Imports
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.system.Security;

import mx.events.ListEvent;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

import org.freesound.Sound;
import org.freesound.SoundCollection;
import org.freesound.User;


// Initialize sound collection object
private var sc:SoundCollection = new SoundCollection(apiKey);

// Initialize user object (to store single user information)
private var u:User = new User(apiKey);

// Initialize sound object (to store single sound information, not audio but other info)
// We need to declare the variable with the full type path (org.freesound.Sound) to avoid confussion with flash.media.Sound
private var s:org.freesound.Sound = new org.freesound.Sound(apiKey);

// Initialize soundchannel object to reproduce sounds
private var schannel:SoundChannel = new SoundChannel();

// Request ID
private var requestId:int = 0;
private var displayedRequestId:int = 0;

// Initialize current display information
private var currentDisplayInfo:String = "description";

// Allow data from tabasco.upf.edu (to avoid sandbox violation errors)
public function init():void{
	Security.allowDomain("http://www..freesound.org");
}

private function search(query:String):void 
{
	
	// QUERYING FREESOUND
	// ******************
	
	// We use the SoundCollection object as the result of the query will be a collection of sounds (only its information, not its audio data)	
	// With the "All results mode" checkbox we can change the behaviour of the results display:
	//	- All results mode ON: we obtain as many results as the specified in the "Max results" input box.
	//                         All results are displayed in one single page, and the time needed to load depends on "Max results"
	//  - All results mode OFF: we obtain paginated results. First 30 results are displayed and following pages can be navigated with "next" and "previous" buttons.
	
	if (!this.modeCheckbox.selected){
		sc.getSoundsFromQuery({q:query, request_id:requestId}); // "q" parameter specifies the query. More options like filters are available as described in the API (http://tabasco.upf.edu/media/docs/api/resources.html#resources)
	}else{
		sc.getNSoundsFromQuery({q:query, request_id:requestId},(int)(this.inputBoxNResults.text));
	}
	
	this.requestId = this.requestId + 1;
	
	// When this method is called, "sc" will request the information to Freesound. Once recieved, it will be loaded into its attributes. 
	// In order to know when is the information available, "sc" dispatches a "GotSoundCollection" event that should be catched with an EventListener.
	// Thus, we add an event listener that executes "displayQueryResults" when requested information is ready.
	sc.addEventListener("GotSoundCollection", displayQueryResults);
	
	// We can add also a fault even listener to be aware of any errors
	sc.addEventListener(FaultEvent.FAULT, faultHandler);
		
}

private function displayQueryResults(event:ResultEvent):void
{
	// Only update the results if the information on sc.request_id corresponds to a newer response than the currently displayed
	if ((sc.request_id >= this.displayedRequestId)||(sc.request_id==0)){
		this.displayedRequestId = sc.request_id;
	
		// We fill the resultsBox with the information of the query results
		var info:String = "";
		
		// Number of results
		info = info + sc.num_results + " results found. Displaying page " + sc.current_page + "/" + sc.num_pages + ".\n\n";
		this.resultsBox.text = info;
		
		// Individual results (only first page is displayed, 30 results)
		// To navigate among other results, "next" and "previous" buttons must be used.
		this.resultsGrid.dataProvider = sc.soundList;
		
		// Enable and disable "previous" and "next" buttons
		if (sc.num_pages > 1){
		
			if (sc.current_page == 1){
				this.prevButton.enabled = false;
			}else{
				this.prevButton.enabled = true;
			}
			
			if (sc.current_page == sc.num_pages){
				this.nextButton.enabled = false;
			}else{
				this.nextButton.enabled = true;
			}
		}else{
			this.nextButton.enabled = false;
			this.prevButton.enabled = false;
		}
	}

}

private function next():void
{
	// next() funciton in SoundCollection performs a new query to freesound with the same parameters but asking for the following page.
	// Therefore, when the results are received, a "GotSoundCollection" event is dispatched and "displayQueryResults" is called again.
	sc.nextPage();
}

private function previous():void
{
	// previous() function in SoundCollection works similar to next() but asking for the previous page.
	sc.previousPage();	
}

private function similar():void
{
	// similar() function is used to fill the current SoundCollection object with similar sounds to the selected one
	sc.getSimilarSoundsFromSoundId(this.s.info['id'],"music",25);
	sc.current_page = 1;
	sc.num_pages = 1;
	sc.addEventListener("GotSoundCollection", displayQueryResults);
	sc.addEventListener(FaultEvent.FAULT, faultHandler);
}

private function toggleAnalysisDescription():void
{
	if (currentDisplayInfo == "description"){
		// Switching to show analysis
		this.currentDisplayInfo = "analysis";
		this.analysisDescriptionButton.label = "Show me sound description!";
		this.analysisDescriptionLabel.text = "sound analysis:";
		// We ask for analysis information (through a request to the API)
		s.getSoundAnalysis();
		s.addEventListener("GotSoundAnalysis", displaySoundAnalysis);
		s.addEventListener(FaultEvent.FAULT, faultHandler);
		this.analysisDescriptionBox.text = "retrieving analysis data..."
			
	}else if (currentDisplayInfo == "analysis"){
		// Switching to show description
		this.currentDisplayInfo = "description";
		this.analysisDescriptionButton.label = "Show me sound analysis!";
		this.analysisDescriptionLabel.text = "sound description:";
		this.analysisDescriptionBox.text = s.info['description'];
		
	}
}

private function toggleAllResultsMode():void
{
	if (this.modeCheckbox.selected){
		this.inputBoxNResults.enabled = true;
	}else{
		this.inputBoxNResults.enabled = false;
	}
}

private function faultHandler(event:FaultEvent):void
{
	// If we find any errors we print it on the results box text area.
	this.resultsBox.text = event.toString();
}

// Function to handle user clicks in the data grid
private function gridItemClick(event:ListEvent):void 
{
	// When a result is selected, its waveform is loaded
	this.waveformDisplay.source = this.resultsGrid.dataProvider[event.rowIndex].info['waveform_l'];
	this.spectrumDisplay.source = this.resultsGrid.dataProvider[event.rowIndex].info['spectral_l'];
	
	// And we also ask for extended information on the sound 
	// (like its description, which is not included in the query result but can be accessed through sound reference)
	this.s.getSoundFromRef(this.resultsGrid.dataProvider[event.rowIndex].info['ref']);
	// We add the event listener that will be triggered when server returns sound information
	s.addEventListener("GotSoundInfo", displaySoundInformation);
	
	// Moreover, data from its user is loaded
	this.u.getUserFromRef(this.resultsGrid.dataProvider[event.rowIndex].info['user']['ref']);
	// We add the event listener that will be triggered when server returns user information
	u.addEventListener("GotUserInfo", displayUserInformation); 
}

// Function to handle user double clicks in the data grid
private function gridItemDoubleClick(event:ListEvent):void 
{
	
	// When a result is double clicked, it is reproduced
	schannel.stop();
	var snd:flash.media.Sound = new flash.media.Sound();
	snd.addEventListener(Event.COMPLETE,onSoundLoadComplete);
	
	var req:URLRequest = new URLRequest(this.resultsGrid.dataProvider[event.rowIndex].info['preview-lq-mp3'] + "?api_key=" + apiKey);
	snd.load(req);
}

private function onSoundLoadComplete(event:Event):void
{
	// When sound is loaded, start reproducing
	var localSound:flash.media.Sound = event.target as flash.media.Sound;
	schannel = localSound.play();
}

// Functions to display specific sound and user information
private function displayUserInformation(event:ResultEvent):void
{
	this.userName.text = u.info['username'] + " (joined "+ u.info.date_joined + ")";
}

private function displaySoundInformation(event:ResultEvent):void
{
	this.soundName.text = s.info['original_filename'];
	this.soundDuration.text = "Duration : " + s.info['duration'] + " seconds | Uploaded: " + s.info['created'];
	this.currentDisplayInfo = "description";
	this.analysisDescriptionButton.label = "Show me sound analysis!"
	this.analysisDescriptionLabel.text = "sound description:"
	this.analysisDescriptionBox.text = s.info['description'];
	this.similarButton.enabled = true;
	this.analysisDescriptionButton.enabled = true;
}

private function displaySoundAnalysis(event:ResultEvent):void
{
	// getSoundAnalysis() returns an object (s.analysis) with a lot of properties about the sound. In this example we only print some of them.
	// For more information about what are those properties check the Freesound API documentation at: http://tabasco.upf.edu/docs/api/
	
	var analysis_string:String = "";
	analysis_string = analysis_string + "lowlevel" + "\n\taverage_loudnes: " + s.analysis['lowlevel']['average_loudness'].toString();
	analysis_string = analysis_string + "\nhighlevel" + "\n\tvoice_instrumental: " + s.analysis['highlevel']['voice_instrumental']['value'].toString();
	analysis_string = analysis_string + "\n\tacoustic: " + s.analysis['highlevel']['acoustic']['value'].toString();
	analysis_string = analysis_string + "\n\telectronic: " + s.analysis['highlevel']['electronic']['value'].toString();
	analysis_string = analysis_string + "\ntonal" + "\n\tkey_key: " + s.analysis['tonal']['key_key'].toString();
	analysis_string = analysis_string + "\n\tkey_scale: " + s.analysis['tonal']['key_scale'].toString();
	
	this.analysisDescriptionBox.text = analysis_string;
	
}
