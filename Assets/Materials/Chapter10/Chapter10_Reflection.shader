// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unity Shaders Book/Chapter 10/Chapter10_Reflection"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
		_ReflectionColor("Color",Color)= (1,1,1,1)
		_ReflectionAmount("ReflectionAmount",Range(0,1))=1
		_Cubemap("Cubemap",Cube)="_Skybox"{}

    }
    SubShader
    {
		Pass 
		{
			Tags{"LightMode"="ForwardBase" }
			CGPROGRAM
				#pragma multi_compile_fwdbase 
				#pragma vertex vert 
				#pragma fragment frag 

				#include "Lighting.cginc"
				#include "AutoLight.cginc"

				fixed4 _Color;
				fixed4 _ReflectionColor;
				fixed _ReflectionAmount;
				samplerCUBE _Cubemap;

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
					float3 worldReflect:TEXCOORD2;
					float3 worldViewDir:TEXCOORD3;
					SHADOW_COORDS(4)
				};

				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldNormal = UnityObjectToWorldNormal(v.normal);
					o.worldPos = mul(unity_ObjectToWorld,v.vertex);
					o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
					o.worldReflect = reflect(-o.worldViewDir,o.worldNormal);
					TRANSFER_SHADOW(o);
					return o;
				}
				fixed4 frag(v2f i):SV_Target 
				{
					fixed3 worldNormal = normalize(i.worldNormal);
					fixed3 worldViewDir = normalize(i.worldViewDir);
					fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
					
					fixed3 diffuse = _LightColor0*_Color*saturate(dot(worldNormal,worldLightDir));
					UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
					fixed3 reflection = texCUBE(_Cubemap,i.worldReflect)*_ReflectionColor;
					return fixed4(ambient+lerp(diffuse,reflection,_ReflectionAmount)*atten,1.0);

				}
				ENDCG
		}

    }
    FallBack "Diffuse"
}
