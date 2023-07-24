Shader "Custom/Uv/PoolarCoords"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

        Blend SrcAlpha OneMinusSrcAlpha

        ZWrite off
        Cull off

        Pass
        {

            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST;


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                half2 center = half2(0.5, 0.5);
                o.uv = v.uv - center;

                o.color = v.color;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                i.uv = half2(atan2(i.uv.y, i.uv.x) / (2.0f * 3.141592653589f), length(i.uv));
                i.uv *= _MainTex_ST.xy;

                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;

                return col;
            }

            ENDCG
        }
    }
    CustomEditor "ShaderFeatureCustom"
}