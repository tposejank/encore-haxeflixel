package encore.states;

import encore.backend.AssetPaths;
import encore.backend.audio.StemGroup;
import encore.backend.data.InfoJson;
import encore.backend.midi.MidiHandler;
import flixel.FlxG;
import flixel.sound.FlxSound;
import grig.midi.MidiFile;
import grig.midi.file.event.TextEvent;
import haxe.display.Display.Package;
import json2object.JsonParser;

class PlayState extends GameState
{
	var fullSound:FlxSound;
	var song:MidiSong;

	override public function create()
	{
		MidiHandler.instance = new MidiHandler();

		var midiFile:MidiFile = MidiHandler.instance.midiFile('Songs/24kmagic/notes.mid');
		song = MidiHandler.instance.createSong(midiFile);
		song.validateTimes();

		var infoJsonPath:String = 'Songs/24kmagic/info.json';

		var parser = new json2object.JsonParser<InfoJson>();
		parser.fromJson(Paths.getText(infoJsonPath));
		var data:InfoJson = parser.value;

		var stemPaths:StemPaths = new StemPaths(data.stems);
		trace('Playing');
		var stems:StemGroup = new StemGroup('Songs/24kmagic/', stemPaths);

		stems.loadAll();
		stems.playAll();

		super.create();
	}

	override public function update(elapsed:Float)
	{
		//trace('-----------------');

		// for (track in song.tracks) {
		// 	if (track.trackName == 'PART VOCALS') {
		// 		for (event in track.events) {
		// 			if (event.pitch < 96 || event.pitch > 100) continue;

		// 			if (fullSound.time > (event.time * 1000)) {
		// 				trace('HIT NOTE AT ${event.pitch}');
		// 				track.events.remove(event);
		// 			} else {
		// 				//trace('Not hit note! ${event.time}');
		// 			}
		// 		}
		// 	}
		// }

		super.update(elapsed);
	}
}
