Shader "Custom/Uv/Doodle"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        
        _Amount ("Hand Drawn Amount", Range(0, 20)) = 10
        _Speed ("Hand Drawn Speed", Range(0, 5)) = 2
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

            half _Amount, _Speed;

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
                _Speed = (floor(_Time.y * 20 * _Speed) / _Speed) * _Speed;
                uvCopy.x = sin(uvCopy.x * _Amount + _Speed);
                uvCopy.y = cos(uvCopy.y * _Amount + _Speed);
                i.uv = lerp(i.uv, i.uv + uvCopy, 0.0005 * _Amount);
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;

                return col;
            }

            ENDCG
        }
    }
}