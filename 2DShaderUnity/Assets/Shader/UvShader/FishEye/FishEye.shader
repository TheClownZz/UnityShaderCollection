Shader "Custom/Uv/FishEys"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        
        _FishEyeUvAmount ("Fish Eye Amount", Range(0, 0.5)) = 0.35
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

            half _FishEyeUvAmount;

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
                half2 center = half2(0.5, 0.5);
                half2 centerTiled = half2(center.x * _MainTex_ST.x, center.y * _MainTex_ST.y);
                half bind = length(centerTiled);
                half2 dF = i.uv - centerTiled;
                half dFlen = length(dF);
                half fishInt = (3.14159265359 / bind) * (_FishEyeUvAmount + 0.001);
                i.uv = centerTiled + (dF / (max(0.0001, dFlen))) * tan(dFlen * fishInt) * bind / tan(bind * fishInt);

                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;
                return col;
            }

            ENDCG
        }
    }
}