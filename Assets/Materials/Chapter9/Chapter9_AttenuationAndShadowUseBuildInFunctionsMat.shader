Shader "Unity Shaders Book/Chapter 9/Chapter9_AttenuationAndShadowUseBuildInFunctionsMat"
{
    Properties
    {
		_Color("Color Tint", Color)=(1,1,1,1)
		_Specular("Specular",Color)=(1,1,1,1)
		_Gloss("Gloss",Range(8.0,256))=20

    }
    SubShader
    {
		Pass 
		{
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
				#pragma vertex vert 
				#pragma fragment frag
				#pragma multi_compile_fwdbase

				#include "Lighting.cginc"
				#include "AutoLight.cginc"

				fixed4 _Color;
				fixed4 _Specular;
				float _Gloss;

				struct a2v
				{
					float4 vertex:POSITION;
					float4 normal:NORMAL;

				};
				struct v2f
				{
					float4 pos:SV_POSITION;
					float4 worldPos:TEXCOORD0;
					float3 worldNormal:TEXCOORD1;
					SHADOW_COORDS(2)
				};
				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldPos = mul(unity_ObjectToWorld,v.vertex);
					o.worldNormal = UnityObjectToWorldNormal(v.normal);
					TRANSFER_SHADOW(o);
					return o;

				}
				fixed4 frag(v2f i):SV_Target
				{
					fixed3 worldNormal = normalize(i.worldNormal);
					fixed3 worldLightDir =normalize(_WorldSpaceLightPos0.xyz);
					fixed3 ambient  = UNITY_LIGHTMODEL_AMBIENT.xyz;
					fixed3 diffuse = _LightColor0*_Color*saturate(dot(worldNormal,worldLightDir));

					fixed3 worldViewDir = normalize(_WorldSpaceCameraPos-i.worldPos);
					fixed3 halfDir = normalize(worldViewDir+worldLightDir);
					fixed3 specular = _LightColor0*_Specular*pow(saturate(dot(worldNormal,halfDir)),_Gloss);
					//fixed shadow = SHADOW_ATTENUATION(i);
					//fixed atten = 1.0;
					UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

					return fixed4(ambient+(diffuse+specular)*atten,1.0);
				}
			ENDCG
		}
		Pass 
		{
			Tags { "LightMode"="ForwardAdd" }
			Blend One One
			CGPROGRAM
				#pragma vertex vert 
				#pragma fragment frag
				#pragma multi_compile_fwdadd

				#include "Lighting.cginc"
				#include "AutoLight.cginc" 
				//使用unity_WorldToLight矩阵来将坐标转换到光照空间一定要包含AutoLight.cginc文件

				fixed4 _Color;
				fixed4 _Specular;
				float _Gloss;

				struct a2v
				{
					float4 vertex:POSITION;
					float4 normal:NORMAL;

				};
				struct v2f
				{
					float4 pos:SV_POSITION;
					float3 worldPos:TEXCOORD0;
					float3 worldNormal:TEXCOORD1;
				};
				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldPos = mul(unity_ObjectToWorld,v.vertex);
					o.worldNormal = UnityObjectToWorldNormal(v.normal);
					return o;

				}
				fixed4 frag(v2f i):SV_Target
				{
					fixed3 worldNormal = normalize(i.worldNormal);

					#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir =normalize(_WorldSpaceLightPos0.xyz);
					#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz-i.worldPos.xyz);
					#endif
					fixed3 diffuse = _LightColor0*_Color*saturate(dot(worldNormal,worldLightDir));

					fixed3 worldViewDir = normalize(_WorldSpaceCameraPos-i.worldPos);
					fixed3 halfDir = normalize(worldViewDir+worldLightDir);
					fixed3 specular = _LightColor0*_Specular*pow(saturate(dot(worldNormal,halfDir)),_Gloss);

					//#ifdef USING_DIRECTIONAL_LIGHT
					//fixed atten = 1.0;
					//#else 
					//float3 lightCoord = mul(unity_WorldToLight,float4(i.worldPos,1)).xyz;
					//fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;

					//#endif
					UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
					return fixed4((diffuse+specular)*atten,1.0);
				}
			ENDCG
		}
		Pass 
		{
			Name "ShadowCaster"
			Tags{"LightMode"="ShadowCaster"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag 
			#pragma multi_compile_shadowcaster 
			
			#include "UnityCG.cginc"

			struct v2f
			{
				V2F_SHADOW_CASTER;
			};
			v2f vert(appdata_base v)
			{
				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
				return o;
			}
			float4 frag(v2f i):SV_Target 
			{
				SHADOW_CASTER_FRAGMENT(i);
			}
			ENDCG
		}


    }
    //FallBack "Specular"
}