Shader "Unity Shaders Book/Chapter 8/ZtestZwrite"
{
    Properties
    {

    }
    SubShader
    {
        Tags { "RenderType"="Opaque"
			   "Queue"="Geometry"}
		Pass
		{
			
			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag 

			#include "Lighting.cginc"

			float4 vert(float4 v:POSITION):SV_POSITION
			{
				return UnityObjectToClipPos(v);
			}
			fixed4 frag(float4 i:SV_POSITION):SV_Target 
			{
				return fixed4(1,0,0,1);
			}
			ENDCG
		}
    }
    FallBack "Diffuse"
}
