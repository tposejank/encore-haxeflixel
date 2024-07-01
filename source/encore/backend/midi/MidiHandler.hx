package encore.backend.midi;

import grig.midi.MidiFile;
import grig.midi.file.event.MidiMessageEvent;
import grig.midi.file.event.TempoChangeEvent;
import grig.midi.file.event.TextEvent;
import grig.midi.file.event.TimeSignatureEvent;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.Input;
import openfl.Assets;
#if sys
import sys.io.File;
#end

/**
 * Class to handle Event Types in MIDI.
 */
enum abstract NoteEventType(String) to String from String
{
	var NoteOn = 'note_on';
	var NoteOff = 'note_off';
	var Unknown = 'unknown';
}

/**
 * Utility class to read song MIDIs.
 */
class MidiHandler
{
	public static var instance:MidiHandler = null;

	public function new() {}

	/**
	 * Takes in a path and returns `grig.midi.MidiFile`
	 * @param midiPath 
	 * @return MidiFile `grig.midi.MidiFile`
	 */
	public function midiFile(midiPath:String):MidiFile
	{
		#if sys
		var contentBytes:Bytes = File.getBytes(midiPath);
		#else
		var contentBytes:Bytes = Assets.getBytes(midiPath);
		#end
		var fileBytes:Input = new BytesInput(contentBytes);
		var midiFile:MidiFile = MidiFile.fromInput(fileBytes);
		return midiFile;
	}

	/**
	 * Reads a text event with its bytes
	 * @param textEvent text event object
	 * @return `String`: text event string
	 */
	public function getTextEventContents(textEvent:Dynamic)
	{
		return textEvent.bytes.getString(0, textEvent.bytes.length);
	}

	/**
	 * Calculates the denominator of a time signature change with the given denominator exponent
	 * @param denominatorExponent Denominator exponent of a Midi time signature event
	 * @return Int
	 */
	public function denominatorOfExponent(denominatorExponent:Int):Int
	{
		return Math.ceil(Math.pow(2, denominatorExponent));
	}

	// Thanks, mido!

	/**
	 * Converts tempo (micro seconds per quarter note) to BPM.
	 * @param tempo Tempo
	 * @param timeSignature the time signature at which the tempo change occurs. (Denominator used, `Array<Int>`)
	 */
	public function tempo2bpm(tempo:Int, timeSignature:Array<Int>)
	{
		return 60 * 1e6 / tempo * timeSignature[1] / 4.;
	}

	/**
	 * Checks if a track is valid.
	 * @param trackName The track name.
	 */
	public function isValidTrack(trackName:String)
	{
		return [
			'PART DRUMS', 'PLASTIC DRUMS', 'PART GUITAR', 'PLASTIC GUITAR', 'PART BASS', 'PLASTIC BASS', 'PART VOCALS', 'BEAT', 'SECTION', 'EVENTS'
		].contains(trackName);
	}

	/**
	 * Calculates the type of event of a note event.
	 * @param noteEventType `Int` (byte 0) of the event
	 * @return `note_on`, `note_off`, `unknown` (if unknown type)
	 */
	public function getNoteEventType(noteEventType:Int):NoteEventType
	{
		if (noteEventType == 128)
		{
			return NoteEventType.NoteOff;
		}
		else if (noteEventType == 144)
		{
			return NoteEventType.NoteOn;
		}

		return NoteEventType.Unknown;
	}

	/**
	 * Calculates time in beats using the MIDI ticks of an event.
	 * @param bpm The current BPM
	 * @param ticksSince Ticks since the last event
	 * @param PPQN MIDI PPQ, 480
	 */
	public function getTimeInBeats(bpm:Float, ticksSince:Float, PPQN:Int = 480)
	{
		var beatCrochet:Float = (60 / bpm);
		var timeSinceLastInBeats:Float = ticksSince / PPQN;
		return beatCrochet * timeSinceLastInBeats;
	}

	/**
	 * Creates a song using a midi file object
	 * @param midiFile 
	 * @return MidiSong the song obviously
	 */
	public function createSong(midiFile:MidiFile):MidiSong
	{
		var song:MidiSong = new MidiSong();

		var tempoChangeEvents:Array<Dynamic> = [];
		var timeSignatureChangeEvents:Array<Dynamic> = [];

		for (track in midiFile.tracks)
		{
			var miditrack:MidiTrack = new MidiTrack();

			var textEvents:Array<Dynamic> = [];
			var noteEvents:Array<Dynamic> = [];

			for (event in track.midiEvents)
			{
				if (event is TextEvent)
				{
					textEvents.push(event);
				}
				else if (event is MidiMessageEvent)
				{
					noteEvents.push(event);
				}
				else if (event is TempoChangeEvent)
				{
					tempoChangeEvents.push(event);
				}
				else if (event is TimeSignatureEvent)
				{
					timeSignatureChangeEvents.push(event);
				}
			}

			var trackName:String = null;

			for (textEvent in textEvents)
			{
				var textContent:String = getTextEventContents(textEvent);
				var absTime:Int = textEvent.absoluteTime;

				if (textEvent.textEventType == TextEventType.SequenceName)
				{
					trackName = textContent;
				}

				// trace('Text Event: ${textContent}');
				var midievent:MidiTextEvent = new MidiTextEvent(textContent, absTime);
				miditrack.events.push(midievent);
			}

			var heldNotes:Map<Int, Array<Dynamic>> = [];
			for (noteEvent in noteEvents)
			{
				var notePitch:Int = noteEvent.midiMessage.get(1);
				var eventType:NoteEventType = getNoteEventType(noteEvent.midiMessage.get(0));
				var absTime:Int = noteEvent.absoluteTime;

				if (eventType == 'note_on')
				{
					heldNotes[notePitch] = [notePitch, absTime];
				}
				else if (eventType == 'note_off')
				{
					var midieventon = heldNotes[notePitch];
					var midinote:MidiNote = new MidiNote(notePitch, absTime - midieventon[1], midieventon[1]);
					// trace('Note Placed: Pitch: ${notePitch}, Length: ${midinote.length}');
					miditrack.events.push(midinote);
				}
			}

			if (!isValidTrack(trackName))
			{
				for (tempoEvent in tempoChangeEvents)
				{
					var absTime:Int = tempoEvent.absoluteTime;
					var mspqn:Int = tempoEvent.microsecondsPerQuarterNote;

					// trace('Tempo Change Event!: Time: ${absTime} MSPQN: ${mspqn}');

					var event:MidiTempoChangeEvent = new MidiTempoChangeEvent(mspqn, absTime);
					song.tempoTimeSigChanges.push(event);
				}

				for (timeSignatureEvent in timeSignatureChangeEvents)
				{
					var absTime:Int = timeSignatureEvent.absoluteTime;
					var numerator:Int = timeSignatureEvent.numerator;
					var denominator:Int = denominatorOfExponent(timeSignatureEvent.denominatorExponent);
					var de:Int = timeSignatureEvent.denominatorExponent;

					// trace('Time Signature Event!: Time: ${absTime} N: ${numerator} D: ${denominator}');

					var event:MidiTimeSigChange = new MidiTimeSigChange(numerator, denominator, de, absTime);
					song.tempoTimeSigChanges.push(event);
				}
			}

			miditrack.trackName = trackName;
			song.tracks.push(miditrack);
		}

		return song;
	}
}

/**
 * Midi text event.
 */
class MidiTextEvent extends MidiEvent
{
	public var textContents:String;

	/**
	 * Time in ms it occurs
	 */
	public var time:Float;

	/**
	 * Creates a midi text event object
	 * @param textContents The text content
	 * @param absoluteTime (Parent class MidiEvent) absolute time.
	 */
	public function new(textContents:String, absoluteTime:Int)
	{
		super(absoluteTime);
		this.textContents = textContents;
		this.time = 0;
	}
}

/**
 * Midi Note, extends Midi Event.
 */
class MidiNote extends MidiEvent
{
	/**
	 * Time in MS it occurs
	 */
	public var time:Float; // ms

	/**
	 * Pitch of the note
	 */
	public var pitch:Int;

	public var length:Float; // ticks

	/**
	 * Length in milliseconds the note lasts for,
	 * 0 if not supposed to be a hold note!!
	 */
	public var lengthMS:Float;

	/**
	 * Creates a Midi Note object.
	 * @param pitch Pitch of the note
	 * @param length Lenght in ticks
	 * @param absoluteTime (Parent class) absolute time
	 */
	public function new(pitch:Int, length:Float, absoluteTime:Int)
	{
		super(absoluteTime);
		this.time = 0;
		this.pitch = pitch;
		this.length = length;
	}
}

/**
 * Midi event
 */
class MidiEvent
{
	public var absoluteTime:Int;

	public function new(absoluteTime:Int)
	{
		this.absoluteTime = absoluteTime;
	}
}

/**
 * Midi track
 */
class MidiTrack
{
	public var trackName:String;
	public var events:Array<Dynamic>;

	/**
	 * Midi track
	 * @param trackName The track's name
	 */
	public function new(trackName:String = '')
	{
		this.events = [];
		this.trackName = trackName;
	}
}

/**
 * Tempo change event
 */
class MidiTempoChangeEvent extends MidiEvent
{
	public var tempo:Int;
	public var bpm:Float;
	public var time:Float;

	/**
	 * The tempo change constructor
	 * @param tempo Microseconds per quarter note
	 * @param absoluteTime absolute time at which it occurs(parent class)
	 */
	public function new(tempo:Int, absoluteTime:Int)
	{
		super(absoluteTime);
		this.tempo = tempo;
	}
}

/**
 * Time signature event
 */
class MidiTimeSigChange extends MidiEvent
{
	public var n:Int;
	public var d:Int;
	public var de:Int;
	public var time:Float;
	public var bpm:Float;

	/**
	 * Time signature event constructor
	 * @param numerator the numerator of the TS
	 * @param denominator the denominator of the TS (USE THIS ONE!)
	 * @param de the denominator exponented of the TS
	 * @param absoluteTime The absolute time at which it occurs (Parent class)
	 */
	public function new(numerator:Int, denominator:Int, de:Int, absoluteTime:Int)
	{
		super(absoluteTime);
		this.n = numerator;
		this.d = denominator;
		this.de = de;
	}
}

/**
 * Every array that isn't `MidiTrack` or `MidiEvent` is `Dynamic`!
 * 
 * This is because Haxe is stupid!
 * 
 * Midi Song.
 * - `tracks`: Array of tracks.
 * - `tempoTimeSigChanges`: Array of tempo and time signature changes.
 */
class MidiSong
{
	public var tracks:Array<MidiTrack>;
	public var tempoTimeSigChanges:Array<Dynamic>;

	public function new()
	{
		this.tracks = [];
		this.tempoTimeSigChanges = [];
	}

	public function findBPMAtTick(ticks:Int):Dynamic
	{
		if (tempoTimeSigChanges.length > 0)
		{
			if (ticks <= tempoTimeSigChanges[0].absoluteTime)
			{
				return tempoTimeSigChanges[0];
			}
		}

		for (i in 1...tempoTimeSigChanges.length - 1)
		{
			var currentEvent = tempoTimeSigChanges[i];
			var previousEvent = tempoTimeSigChanges[i - 1];

			if (previousEvent.absoluteTime <= ticks && currentEvent.absoluteTime >= ticks)
			{
				// trace('the event matched with ${previousEvent.absoluteTime}, i ${i}');
				return previousEvent;
			}
		}

		return null;
	}

	/**
	 * Validate all events' absolute times into milliseconds.
	 */
	public function validateTimes()
	{
		validateBPMTS();

		for (track in tracks)
		{
			trace('parsing ${track.trackName}');

			for (event in track.events)
			{
				var noteBPM = findBPMAtTick(event.absoluteTime);
				var ticksSinceLast = event.absoluteTime;

				if (noteBPM != null)
				{
					ticksSinceLast = event.absoluteTime - noteBPM.absoluteTime;

					var eventTime = MidiHandler.instance.getTimeInBeats(noteBPM.bpm, ticksSinceLast);
					var currentTimeMs = eventTime;
					event.time = noteBPM.time + currentTimeMs;
					// trace('Note time is ${event.time} with bpm ${noteBPM.bpm} which changed at time ${noteBPM.time}');
				}
				else
				{
					trace('WARNING: Bpm event is NULL! Note ${event.absoluteTime} TIME ${event.time} tried accessing a NULL bpm event!');
				}
			}
		}
	}

	/**
	 * Validates bpm and time signature events times
	 * 
	 * Call this to validate these times
	 * 
	 * Called by `validateTimes`, of `MidiSong`.
	 */
	public function validateBPMTS()
	{
		var previousTimeSignature:Array<Int> = [4, 4];
		var previousEvent:Dynamic = null;
		var currentTimeMs:Float = 0.0;

		tempoTimeSigChanges.sort(function(a, b)
		{
			return a.absoluteTime - b.absoluteTime;
		});

		for (event in tempoTimeSigChanges)
		{
			if (event is MidiTimeSigChange)
			{
				var previousBPM = 120.0;
				var ticksSinceLast = event.absoluteTime;
				if (previousEvent != null)
				{
					previousBPM = previousEvent.bpm;
					ticksSinceLast = event.absoluteTime - previousEvent.absoluteTime;
				}

				var eventTime = MidiHandler.instance.getTimeInBeats(previousBPM, ticksSinceLast);
				currentTimeMs += eventTime;

				event.bpm = previousBPM;
				event.time = currentTimeMs;
				// trace(event.n, event.d, event.bpm, event.time);

				previousEvent = event;
			}
			else if (event is MidiTempoChangeEvent)
			{
				var previousBPM = 120.0;
				var ticksSinceLast = event.absoluteTime;
				if (previousEvent != null)
				{
					previousBPM = previousEvent.bpm;
					ticksSinceLast = event.absoluteTime - previousEvent.absoluteTime;
				}

				var eventTime = MidiHandler.instance.getTimeInBeats(previousBPM, ticksSinceLast);
				currentTimeMs += eventTime;

				event.bpm = MidiHandler.instance.tempo2bpm(event.tempo, previousTimeSignature);
				event.time = currentTimeMs;

				// trace(event.tempo, event.bpm, event.time);

				previousEvent = event;
			}
		}
	}
}