package encore.backend.shaders;

import flixel.system.FlxAssets.FlxShader;

class MenuBlur extends FlxShader
{
    // I DO NOT KNOW WHAT I AM DOING!!!
	@:glFragmentSource('
#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
#define iChannel0 bitmap

// third argument fix
vec4 flixel_texture2D(sampler2D bitmap, vec2 coord, float bias) {
	vec4 color = texture2D(bitmap, coord, bias);
	if (!hasTransform)
	{
		return color;
	}
	if (color.a == 0.0)
	{
		return vec4(0.0, 0.0, 0.0, 0.0);
	}
	if (!hasColorTransform)
	{
		return color * openfl_Alphav;
	}
	color = vec4(color.rgb / color.a, color.a);
	mat4 colorMultiplier = mat4(0);
	colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
	colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
	colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
	colorMultiplier[3][3] = openfl_ColorMultiplierv.w;
	color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);
	if (color.a > 0.0)
	{
		return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
	}
	return vec4(0.0, 0.0, 0.0, 0.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float Pi = 6.28318530718; // Pi*2
    

	// nerfed af because it thugs the shit out of your gpu
    // GAUSSIAN BLUR SETTINGS {{{
    float Directions = 30.0;
    float Quality = 2.0;
    float Size = 10.0;
    // GAUSSIAN BLUR SETTINGS }}}
   
    vec2 Radius = Size/iResolution.xy;
    
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    // Pixel colour
    vec4 Color = texture(iChannel0, uv);
    
    // Blur calculations
    for( float d=0.0; d<Pi; d+=Pi/Directions)
    {
		for(float i=1.0/Quality; i<1.001; i+=1.0/Quality)
        {
			Color += texture( iChannel0, uv+vec2(cos(d),sin(d))*Radius*i);		
        }
    }
    
    // Output to screen
    Color /= Quality * Directions +1.0;
    fragColor =  Color;
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}
')
	public function new()
	{
		super();
	}

    // public function setTime(time:Float) {
    //     this.time.value[0] = time;
    // }

    // public function getTime():Float {
    //     return this.time.value[0];
    // }
}
