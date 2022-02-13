// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unity Shaders Book/Chapter 10/Chapter10_Fresnel"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
		_FresnelScale("FresnelScale",Range(0,1))=0.5
		_Cubemap("Cubemap",Cube)="_Skybox"{}
		_FresnelColor("FresnelColor",Color) = (1,1,1,1)
		_FresnelWide("FresnelWide",Range(1,10))=1.5


    }
    SubShader
    {
		Pass 
		{
			Tags{"LightMode"="ForwardBase"}
			CGPROGRAM
				#pragma multi_compile_fwdbase 
				#pragma vertex vert 
				#pragma fragment frag 

				#include "Lighting.cginc"
				#include "AutoLight.cginc"

				fixed4 _Color;
				fixed _FresnelScale;
				fixed4 _FresnelColor;
				samplerCUBE _Cubemap;
				float _FresnelWide;

				struct a2v 
				{
					float4 vertex:POSITION;
					float3 normal:NORMAL;

				};
				struct v2f 
				{
					float4 pos:SV_POSITION;
					float4 worldPos:TEXCOORD0;
					float3 worldNormal:TEXCOORD1;
					float3 worldViewDir:TEXCOORD2;
					float3 worldReflect:TEXCOORD3;
					SHADOW_COORDS(4)
				};
				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldPos = mul(unity_ObjectToWorld,v.vertex);
					o.worldNormal = UnityObjectToWorldNormal(v.normal);
					o.worldViewDir = UnityWorldSpaceViewDir(v.vertex);
					o.worldReflect = reflect(-o.worldViewDir,o.worldNormal);
					TRANSFER_SHADOW(o);
					return o;
				}
				fixed4 frag(v2f i):SV_Target 
				{
					fixed3 worldNormal = normalize(i.worldNormal);
					fixed3 worldViewDir = normalize(i.worldViewDir);
					fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));

					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

					fixed3 diffuse = _LightColor0*_Color*saturate(dot(worldLight,worldNormal));

					fixed3 reflection  = texCUBE(_Cubemap,i.worldReflect);
					fixed3 fresnel = _FresnelScale+(1-_FresnelScale)*pow((1-dot(worldViewDir,worldNormal)),_FresnelWide);
					UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
					//fixed3 color = ambient + lerp(diffuse,reflection,saturate(fresnel))*atten;
					fixed3 color = ambient + (diffuse+saturate(fresnel)*_FresnelColor)*atten;
					return fixed4(color,1.0);
				}
			ENDCG
		}
    }
    FallBack "Diffuse"
}
