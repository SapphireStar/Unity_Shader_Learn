Shader "Unity Shaders Book/Chapter 8/Chapter8_AlphaBlendZWrite"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
		_AlphaScale("AlphaScale",Range(0,1))=1
    }
    SubShader
    {			
	Tags { "Queue"="Transparent" "IgnoreProjecter"="True" "RenderType"="Transparent" }

		Pass
		{
			ZWrite On
			ColorMask 0
		}

		Pass
		{        
			Tags{"Lighting"="ForwardBase"}

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;	
			fixed4 _MainTex_ST;
			fixed _AlphaScale;

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};
			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				fixed2 uv:TEXCOORD2;
			};
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal =UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed4 albedo = tex2D(_MainTex,i.uv);
				fixed3 diffuse = _LightColor0.rgb*albedo.rgb*saturate(dot(worldNormal,worldLight));
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT*albedo;
				return fixed4(diffuse+ambient,albedo.a*_AlphaScale);
			}
			
			ENDCG
		}

    }
    FallBack "Transparent/VertexLit"
}
