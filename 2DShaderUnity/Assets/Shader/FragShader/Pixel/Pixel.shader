Shader "Custom/Frag/Pixel"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        
        _PixelateSize ("Pixelate size", Range(4, 512)) = 32 //50
        _AlphaCutoffValue ("Alpha cutoff value", Range(0, 1)) = 0.25 //70

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

            half _PixelateSize;
            half _AlphaCutoffValue;


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
                o.color = v.color;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 col = tex2D(_MainTex, floor(i.uv * _PixelateSize) / _PixelateSize);
                col *= i.color;
                clip((1 - _AlphaCutoffValue) - (1 - col.a) - 0.01);

                return col;
            }

            ENDCG
        }
    }
}