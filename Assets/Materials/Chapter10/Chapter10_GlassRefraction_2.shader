Shader "Unity Shaders Book/Chapter 10/Chapter10_GlassRefraction_2"
{
    Properties
    {
		_MainTex("Main Tex",2D) = "white"{}
		_Bumpmap("Bumpmap", 2D)="bump"{}
		_Cubemap("Environment Cubemap",Cube)="_Skybox"{}
		_Distortion("Distortion",Range(0,100)) = 50
		_RefractionAmount("Refraction Amount",Range(0,1))=1.0
		_RefractionTex("Refraction Tex",2D)="white"{}
    }
    SubShader
    {
			Tags{"Queue"="Transparent" "RenderType"="Opaque"}

		//GrabPass{"_RefractionTex"}
		Pass 
		{
			CGPROGRAM
				#pragma vertex vert 
				#pragma fragment frag 

				#include "UnityCG.cginc"

				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _Bumpmap;
				float4 _Bumpmap_ST;
				samplerCUBE _Cubemap;
				float _Distortion;
				fixed _RefractionAmount;
				sampler2D _RefractionTex;
				float4 _RefractionTex_TexelSize;

				struct a2v
				{
					float4 vertex:POSITION;
					float3 normal:NORMAL;
					float4 tangent:TANGENT;
					float4 texcoord:TEXCOORD0;

				};
				struct v2f 
				{
					float4 pos:SV_POSITION;
					float4 uv : TEXCOORD0;
					float4 TtoW0 : TEXCOORD1;  
					float4 TtoW1 : TEXCOORD2;  
					float4 TtoW2 : TEXCOORD3; 
					float4 scrPos:TEXCOORD4;
				};

				v2f vert(a2v v)
				{
					v2f o;
					o.pos=UnityObjectToClipPos(v.vertex);
					o.scrPos = ComputeGrabScreenPos(o.pos);//用于获取当前顶点在屏幕上的位置，用于对GrabPass获取到的屏幕截图纹理进行采样
					o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex);
					o.uv.zw = TRANSFORM_TEX(v.texcoord,_Bumpmap);
					float4 worldPos = mul(unity_ObjectToWorld,v.vertex);
					fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
					fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
					fixed3 worldBinormal = cross(worldNormal,worldTangent)*v.tangent.w;

					o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
					o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
					o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);
					
					return o;
				}

				fixed4 frag(v2f i):SV_Target 
				{
					float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
					fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
					fixed3 bump = UnpackNormal(tex2D(_Bumpmap,i.uv.zw));
					float2 offset = bump.xy*_Distortion*_RefractionTex_TexelSize.xy;
					i.scrPos.xy = offset + i.scrPos.xy;
					fixed3 refrCol = tex2Dproj(_RefractionTex,i.scrPos);

					bump = normalize(half3(dot(i.TtoW0,bump),dot(i.TtoW1,bump),dot(i.TtoW2,bump)));
					fixed3 reflDir = reflect(-worldViewDir,bump);
					fixed4 texColor = tex2D(_MainTex,i.uv.xy);
					fixed3 reflCol = texCUBE(_Cubemap,reflDir)*texColor.rgb;

					fixed3 finalColor = reflCol*(1-_RefractionAmount)+refrCol*_RefractionAmount;
					return fixed4(finalColor,1.0);

				}
			
			ENDCG
		}
    }
    FallBack "Diffuse"
}
