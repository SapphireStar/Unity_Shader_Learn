// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "UnityShaderBook/Chapter6/Chapter6_SpecularVertexLevel"
{
    Properties
    {
		_Diffuse ("Diffuse",Color) = (1,1,1,1)
		_Specular ("Specular",Color) =  (1,1,1,1)
		_Gloss ("Gloss",Range(8.0,256)) = 20
    }
    SubShader
    {
		Pass
		{        
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;

			};
			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 color:COLOR;
			};
			v2f vert(a2v v)
			{
				v2f o;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				o.pos=UnityObjectToClipPos(v.vertex);
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				fixed3 diffuse =  _LightColor0.rgb*_Diffuse.rgb*(saturate(dot(worldNormal,worldLight)));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz-mul(unity_ObjectToWorld,v.vertex).xyz);
				fixed3 reflectDir = normalize(reflect(-worldLight,worldNormal));
				fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow((saturate(dot(viewDir,reflectDir))),_Gloss);
				o.color  = ambient+specular+diffuse;
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
				return fixed4(i.color,1.0);
			}
			ENDCG
		}

    }
    FallBack "Diffuse"
}
