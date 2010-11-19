// Include an actionscript file with the API key
// This file must only contain a variable named "apiKey" like: public static const apiKey:String = "YOUR_KEY_HERE";
include "ApiKey.as";

// Import Freesound classes
import org.freesound.Pack;
import org.freesound.PackCollection;
import org.freesound.Sound;
import org.freesound.SoundCollection;
import org.freesound.User;

// Import class
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

// Initialize freesound object to handle lists of sounds (SoundCollection)
private var sc:SoundCollection = new SoundCollection(apiKey);

private function search(query:String):void // Called when the mxml is loaded
{
	
	// QUERYING FREESOUND
	// ******************
	
	// We use the SoundCollection object as the result of the query will be a collection of sounds (only its information, not its audio data)	
	// With the "All results mode" checkbox we can change the behaviour of the results display:
	//	- All results mode ON: we obtain as many results as the specified in the "Max results" input box.
	//                         All results are displayed in one single page, and the time needed to load depends on "Max results"
	//  - All results mode OFF: we obtain paginated results. First 30 results are displayed and following pages can be navigated with "next" and "previous" buttons.
	
	if (!this.modeCheckbox.selected){
		sc.getSoundsFromQuery({q:query}); // "q" parameter specifies the query. More options like filters are available as described in the API (http://tabasco.upf.edu/media/docs/api/resources.html#resources)
	}else{
		sc.getNSoundsFromQuery({q:query},(int)(this.inputBoxNResults.text));
	}
	
	
	// When this method is called, "sc" will request the information to Freesound. Once recieved, it will be loaded into its attributes. 
	// In order to know when is the information available, "sc" dispatches a "GotSoundCollection" event that should be catched with an EventListener.
	// Thus, we add an event listener that executes "displayQueryResults" when requested information is ready.
	sc.addEventListener("GotSoundCollection", displayQueryResults);
	
	// We can add also a fault even listener to be aware of any errors
	sc.addEventListener(FaultEvent.FAULT, faultHandler); 
		
}

private function displayQueryResults(event:ResultEvent):void
{
	// We fill the resultsBox with the information of the query results
	var info:String = "";
	
	// Number of results
	info = info + sc.num_results + " results found. Displaying page " + sc.current_page + "/" + sc.num_pages + ".\n\n";
	
	// Individual results (only first page is displayed, 30 results)
	// To navigate among other results, "next" and "previous" buttons must be used.
	
	for (var i:int=0;i<sc.soundList.length;i++){
		info = info + (i + 1).toString() + " - " + sc.soundList[i].original_filename + "\n";
	}
	
	// Punt information in the results box text area
	this.resultsBox.text = info;
	
	
	// Enable and disable "previous" and "next" buttons
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



