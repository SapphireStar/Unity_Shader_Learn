Shader "Unity Shaders Book/Chapter 11/Chapter11_Test"
{
    Properties
    {
        _Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("MainTex",2D)="white"{}
		_Frequency("Frequency",Float)=1
		_Magnitude("Distortion Magnitude",Float) = 1
		_InvWaveLength("Inverse Wave Length",Float)=5
		_Speed("Speed",Float)=1

    }
    SubShader
    {
		Pass 
		{
			Tags{"LightMode"="ForwardBase"}
			Cull Off
			CGPROGRAM

				#pragma vertex vert 
				#pragma fragment frag 

				#include "UnityCG.cginc"
				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				float _Frequency;
				float _Magnitude;
				float _InvWaveLength;
				float _Speed;
				struct a2v 
				{
					float4 vertex:POSITION;
					float4 texcoord:TEXCOORD0;

				};
				struct v2f 
				{
					float4 pos:SV_POSITION;
					float2 uv:TEXCOORD0;
				};

				v2f vert(a2v v)
				{
					v2f o;
					float4 offset;
					offset.xzw = float3(0,0,0);
					o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
					offset.y = sin(_Frequency*_Time.y*_Speed+v.vertex.z*_InvWaveLength)*_Magnitude*o.uv.y;//为了让不同的顶点在同一时间在不同的位置，加上
					o.pos = UnityObjectToClipPos(v.vertex+offset);
					//o.uv+=float2(0.0,_Time.y*_Speed);
					return o;
				}
				fixed4 frag(v2f i):SV_Target 
				{
					fixed4 c = tex2D(_MainTex,i.uv);
					c*=_Color;
					return c;
				}

			ENDCG
		}
    }

}
