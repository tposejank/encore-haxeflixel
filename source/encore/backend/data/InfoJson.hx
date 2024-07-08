package encore.backend.data;

import hxjsonast.Json;

/**
 * `info.json` structure.
 */
class InfoJson
{
	@:default('Unknown')
	public var title:String;

	@:default('Donald Mustard')
	public var artist:String;

	@:default(0)
	@:optional
	public var preview_start_time:Float;

	@:default('1970')
	@:optional
	public var release_year:String;

	@:default('Unknown')
	@:optional
	public var album:String;

	@:default('Woah it\'s an encore in here!')
	@:optional
	public var loading_phrase:String;

	@:default(['Unknown'])
	@:optional
	public var genres:Array<String>;

	@:default(['Unknown'])
	@:optional
	public var charters:Array<String>;

	@:default(1)
	@:optional
	public var length:Int;

	@:default('Drum')
	@:alias('sid')
	public var icon_drums:String;

	@:default('Bass')
	@:alias('sib')
	public var icon_bass:String;

	@:default('Guitar')
	@:alias('sig')
	public var icon_guitar:String;

	@:default('Vocals')
	@:alias('siv')
	public var icon_vocals:String;

	@:default('notes.mid')
	public var midi:String;

	// no saving you here! you missed, you screwed!
	public var art:String;

	public var stems:Stems;
	// TODO: Difficulties!!
}

// all stems must be an array because we support more than 5 audios
class Stems
{
	@:jcustomparse(encore.backend.data.InfoJson.Stems.forceArrayString)
	@:optional
	@:default([])
	public var drums:Array<String>;

	@:jcustomparse(encore.backend.data.InfoJson.Stems.forceArrayString)
	@:optional
	@:default([])
	public var bass:Array<String>;

	@:jcustomparse(encore.backend.data.InfoJson.Stems.forceArrayString)
	@:optional
	@:default([])
	public var lead:Array<String>;

	@:jcustomparse(encore.backend.data.InfoJson.Stems.forceArrayString)
	@:default(['backing.ogg'])
	public var backing:Array<String>;

	@:jcustomparse(encore.backend.data.InfoJson.Stems.forceArrayString)
	@:optional
	@:default([])
	public var vocals:Array<String>;

	public static function forceArrayString(val:Json, name:String):Array<String>
	{
		switch (val.value)
		{
			case JString(s):
				return [s];
			case JArray(s):
				var newArray:Array<String> = [];
				for (thingy in s)
				{
					switch (thingy.value)
					{
						case JString(s):
							newArray.push(s);
						default: // do nothing
					}
				}

				return newArray;
			default:
				return null;
		}
	}
}