package encore.backend.songs;

import encore.backend.AssetPaths.Paths;
import encore.backend.audio.StemGroup;
import encore.backend.data.InfoJson;
import flixel.FlxG;

class SongHandler
{
	public static var instance:SongHandler;

	public var loadedSongs:Array<SongRegistry>;

	public var currentPlayingStems:StemGroup;

	public function new()
	{
		var songList:Array<String> = Paths.getListOfSongs();

		loadedSongs = [];

		for (song in songList)
		{
			var infoJsonPath = Paths.songFolder + song + '/info.json';
			// trace('Accessing ' + infoJsonPath);

			var parser = new json2object.JsonParser<InfoJson>();
			parser.fromJson(Paths.getText(infoJsonPath));
			var data:InfoJson = parser.value;

			var songRegisterable:SongRegistry = new SongRegistry(data, Paths.songFolder + song + '/');

			loadedSongs.push(songRegisterable);
		}
	}

	public function getAny():SongRegistry
	{
		if (loadedSongs.length > 0)
			return loadedSongs[FlxG.random.int(0, loadedSongs.length - 1)];
		else
			return null;
	}
}

class SongRegistry
{
	public var data:InfoJson;
	public var path:String;

	public function new(data:InfoJson, path:String)
	{
		this.path = path;
		this.data = data;
	}
}