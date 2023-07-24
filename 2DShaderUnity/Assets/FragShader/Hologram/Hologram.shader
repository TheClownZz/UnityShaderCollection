Shader "Custom/Frag/Hologram"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        _HologramStripesAmount ("Stripes Amount", Range(0, 1)) = 0.1
        _HologramUnmodAmount ("Unchanged Amount", Range(0, 1)) = 0.0
        _HologramStripesSpeed ("Stripes Speed", Range(-20, 20)) = 4.5
        _HologramMinAlpha ("Min Alpha", Range(0, 1)) = 0.1 
        _HologramMaxAlpha ("Max Alpha", Range(0, 100)) = 0.75
        _HologramBlend ("Hologram Blend", Range(0, 1)) = 1
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
            half _HologramStripesAmount, _HologramMinAlpha, _HologramUnmodAmount, _HologramStripesSpeed, _HologramMaxAlpha, _HologramBlend;
            half4 _HologramStripeColor;
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

            half RemapFloat(half inValue, half inMin, half inMax, half outMin, half outMax)
            {
                return outMin + (inValue - inMin) * (outMax - outMin) / (inMax - inMin);
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;
                

                half totalHologram = _HologramStripesAmount + _HologramUnmodAmount;
                half hologramYCoord = ((i.uv.y + ((_Time.x % 1) * _HologramStripesSpeed)) % totalHologram) / totalHologram;
                hologramYCoord = abs(hologramYCoord);
                half alpha = RemapFloat(saturate(hologramYCoord - (_HologramUnmodAmount / totalHologram)), 0.0, 1.0, _HologramMinAlpha, saturate(_HologramMaxAlpha));
                half hologramMask = max(sign((_HologramUnmodAmount / totalHologram) - hologramYCoord), 0.0);
                half4 hologramResult = col;
                hologramResult.a *= lerp(alpha, 1, hologramMask);
                hologramResult.rgb *= max(1, _HologramMaxAlpha * max(sign(hologramYCoord - (_HologramUnmodAmount / totalHologram)), 0.0));
                hologramMask = 1 - step(0.01, hologramMask);
                hologramResult.rgb += hologramMask * _HologramStripeColor * col.a;
                col = lerp(col, hologramResult, _HologramBlend);
                return col;
            }

            ENDCG
        }
    }
}