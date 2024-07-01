package encore.backend.macros.release;

#if sys
import sys.FileSystem;
import sys.io.File;
#else
import openfl.Assets;
#end

#if !display
class Release
{
	public static macro function getRelease():haxe.macro.Expr.ExprOf<String>
	{
        #if !display
        var version:String = '';

		#if sys
        if (FileSystem.exists('release.txt')) {
            var release = File.getContent('release.txt');
            version = release;
        }
        #else
        if (Assets.exists('release.txt')) {
            var release = Assets.getText('release.txt');
            version = release;
        }
        #end

        return macro $v{version};
        #else
		var version:String = "";
		return macro $v{version};
        #end
	}
}
#end
