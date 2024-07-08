package;

import encore.backend.CrashHandler;
import encore.backend.display.FPS;
import encore.backend.macros.git.Git;
import encore.backend.macros.release.Release;
import encore.states.HomeMenuState;
import encore.states.PlayState;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	/**
	 * The current Git branch.
	 */
	public static final GIT_BRANCH:String = GitCommit.getGitBranch();

	/**
	 * The current Git commit hash.
	 */
	public static final GIT_HASH:String = GitCommit.getGitCommitHash();

	public static final GIT_LOCAL_CHANGES:String = GitCommit.getGitLocalChanges();

	public static final RELEASE:String = Release.getRelease();

	public static var fpsCounter:FPS;

	public function new()
	{
		CrashHandler.initialize();

		super();
		addChild(new FlxGame(0, 0, HomeMenuState, 180, 180, true));

		fpsCounter = new FPS(10, 3, 0xFFFFFF);

		addChild(fpsCounter);
		FlxG.autoPause = false; // STOP PAUSING ON ME
		FlxG.mouse.useSystemCursor = true;
	}
}
