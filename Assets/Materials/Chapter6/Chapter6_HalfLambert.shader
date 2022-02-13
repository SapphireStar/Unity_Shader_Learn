Shader "UnityShaderBook/Chapter6/Chapter6_HalfLambert"
{
    Properties
    {
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
		_LambertB ("LambertB",float) = 0.5
		_LambertA ("LambertA",float) = 0.5
    }
    SubShader
    {
		Pass
		{        
		Tags { "LightMode" = "ForwardBase" }
        CGPROGRAM

		#pragma vertex vert
		#pragma fragment frag

		#include "Lighting.cginc"

		fixed4 _Diffuse;
		float _LambertB;
		float _LambertA;
		struct a2v
		{	
			float4 vertex:POSITION;
			float3 normal:NORMAL;
		};
		struct v2f
		{
			float4 pos:SV_POSITION;
			float3 worldNormal:NORMAL;
		};
		v2f vert(a2v a)
		{	
			v2f o;
			o.pos=UnityObjectToClipPos(a.vertex);
			o.worldNormal = normalize(mul(a.normal,(float3x3)unity_WorldToObject));
			return o;
		}
		fixed4 frag(v2f i):SV_Target
		{
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
			fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
			fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*(_LambertA*dot(i.worldNormal,worldLight)+_LambertB);
			fixed3 color = diffuse+ambient;
			return fixed4(color,1.0);
		}

        ENDCG

		}

    }
    FallBack "Diffuse"
}
