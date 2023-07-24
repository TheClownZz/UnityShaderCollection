Shader "Custom/Frag/HueShift"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        
        _HsvShift ("Hue Shift", Range(0, 360)) = 180 //43
        _HsvSaturation ("Saturation", Range(0, 2)) = 1 //44
        _HsvBright ("Brightness", Range(0, 2)) = 1 //45

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

            half _HsvShift, _HsvSaturation, _HsvBright;


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

                half3 resultHsv = half3(col.rgb);
                half cosHsv = _HsvBright * _HsvSaturation * cos(_HsvShift * 3.14159265 / 180);
                half sinHsv = _HsvBright * _HsvSaturation * sin(_HsvShift * 3.14159265 / 180);
                resultHsv.x = (.299 * _HsvBright + .701 * cosHsv + .168 * sinHsv) * col.x
                + (.587 * _HsvBright - .587 * cosHsv + .330 * sinHsv) * col.y
                + (.114 * _HsvBright - .114 * cosHsv - .497 * sinHsv) * col.z;
                resultHsv.y = (.299 * _HsvBright - .299 * cosHsv - .328 * sinHsv) * col.x
                + (.587 * _HsvBright + .413 * cosHsv + .035 * sinHsv) * col.y
                + (.114 * _HsvBright - .114 * cosHsv + .292 * sinHsv) * col.z;
                resultHsv.z = (.299 * _HsvBright - .3 * cosHsv + 1.25 * sinHsv) * col.x
                + (.587 * _HsvBright - .588 * cosHsv - 1.05 * sinHsv) * col.y
                + (.114 * _HsvBright + .886 * cosHsv - .203 * sinHsv) * col.z;
                col.rgb = resultHsv;

                return col;
            }

            ENDCG
        }
    }
}