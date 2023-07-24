Shader "Custom/Frag/Flicker"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        _FlickerPercent ("Flicker Percent", Range(0, 1)) = 0.05
        _FlickerFreq ("Flicker Frequency", Range(0, 5)) = 0.2
        _FlickerAlpha ("Flicker Alpha", Range(0, 1)) = 0
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
            half _FlickerFreq, _FlickerPercent, _FlickerAlpha;

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
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;
                col.a *= saturate(col.a * step(frac(0.05 + _Time.w * _FlickerFreq), 1 - _FlickerPercent) + _FlickerAlpha);
                return col;
            }

            ENDCG
        }
    }
}