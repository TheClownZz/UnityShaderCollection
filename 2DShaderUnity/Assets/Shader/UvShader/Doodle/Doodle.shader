Shader "Custom/Uv/Doodle"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        
        _HandDrawnAmount ("Hand Drawn Amount", Range(0, 20)) = 10
        _HandDrawnSpeed ("Hand Drawn Speed", Range(1, 30)) = 5
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

            half _HandDrawnAmount, _HandDrawnSpeed;

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
                half2 uvCopy = i.uv;
                _HandDrawnSpeed = (floor(_Time.y * 20 * _HandDrawnSpeed) / _HandDrawnSpeed) * _HandDrawnSpeed;
                uvCopy.x = sin(uvCopy.x * _HandDrawnAmount + _HandDrawnSpeed);
                uvCopy.y = cos(uvCopy.y * _HandDrawnAmount + _HandDrawnSpeed);
                i.uv = lerp(i.uv, i.uv + uvCopy, 0.0005 * _HandDrawnAmount);
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;

                return col;
            }

            ENDCG
        }
    }
}