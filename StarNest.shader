Shader "Hidden/StarNest"
// https://www.shadertoy.com/view/XlfGRj
{
    Properties
    {
        _Iterations("Iteration",int) = 17
        _Volsteps("Volsteps",int)= 20
        _Formuparam("Formuparam",float) = 0.53
        _Stepsize("Stepsize",float ) = 0.1
        _Zoom("Zoom",float) = 0.800
        _Tile("Tile",float) = 0.850
        _Speed("Speed",float)= 0.010 
        _Brightness("Brightness",float) = 0.0015
        _Darkmatter("Darkmatter",float) = 0.300
        _Distfading("Distfading",float) = 0.730
        _Saturation("Saturation",float) = 0.850
    }

    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"

            int _Iterations,_Volsteps;
            float _Formuparam,_Stepsize,_Zoom,_Tile,_Speed,_Brightness,_Darkmatter,_Distfading,_Saturation;

            fixed4 frag (v2f_img i) : SV_Target
            {
                float4 c;

                //get coords and direction
                fixed2 uv=i.uv-.5;
                fixed3 dir = fixed3(uv*_Zoom,1.);
                fixed time = _Time.y*_Speed+.25;
                fixed3 from = fixed3(1.,.5,0.5);
                from += fixed3(time*2.,time,-2.);
                
                //volumetric rendering
                fixed s = 0.1,fade = 1.0;
                fixed3 v = fixed3(0.,0.,0.);
                for (int r = 0; r < _Volsteps; r ++) 
                {
                    fixed3 p = from + s * dir * .5 ;
                    p = abs(fixed3(_Tile, _Tile, _Tile ) - fmod ( p, fixed3(_Tile * 2., _Tile * 2., _Tile * 2. ) ) ); // tiling fold
                    fixed pa, a = pa = 0.;
                    for ( int i = 0; i < _Iterations; i ++ ) 
                    { 
                        p = abs ( p ) / dot ( p , p ) - _Formuparam; // the magic formula
                        a += abs(length(p) - pa); // absolute sum of average change
                        pa = length(p);
                    }
                    float dm = max(0.,_Darkmatter - a * a * .001); //dark matter
                    a *= a * a; // add contrast
                    if (r > 6) fade *= 1. - dm; // dark matter, don't render near
                    v += fade;
                    v += fixed3(s, s * s, s * s * s * s) * a * _Brightness * fade; // coloring based on distance
                    fade *= _Distfading; // distance fading
                    s += _Stepsize;
                }
                v = lerp(length(v),v,_Saturation); //color adjust
                c = float4(v*0.01,1.);
                return c;	
            }
            ENDCG
        }
    }
}
