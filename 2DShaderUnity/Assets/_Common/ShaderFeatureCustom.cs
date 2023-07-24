using System.Text.RegularExpressions;
using Unity.VisualScripting;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using System.Linq;

public class ShaderFeatureCustom : ShaderGUI
{
    const string shaderFeature = "shader_feature";
    Material targetMat;

    private string[] oldKeyWords;
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        base.OnGUI(materialEditor, properties);
        targetMat = materialEditor.target as Material;

        Shader targetShader = targetMat.shader;

        oldKeyWords = targetMat.shaderKeywords;


        // get path 
        string shaderAssetPath = AssetDatabase.GetAssetPath(targetShader);
        string shaderMetaPath = shaderAssetPath + ".meta";

        // read meta file
        string shaderMetaContent = System.IO.File.ReadAllText(shaderMetaPath);

        // Get shader source
        string shaderSourcePattern = "guid: [a-fA-F0-9]+";
        Match guidMatch = Regex.Match(shaderMetaContent, shaderSourcePattern);
        if (guidMatch.Success)
        {
            string guid = guidMatch.Value.Split(':')[1].Trim();
            string shaderPath = AssetDatabase.GUIDToAssetPath(guid);
            string shaderSource = System.IO.File.ReadAllText(shaderPath);

            HandleShaderFeature(targetMat, shaderSource);
        }
        else
        {
            Debug.Log("Unable to find shader source in the shader meta file.");
        }
    }

    private void HandleShaderFeature(Material targetMat, string content)
    {
        string[] lines = content.Split('\n');

        foreach (string line in lines)
        {
            if (line.Contains(shaderFeature))
            {
                string newLine = line;

                int startIndex = newLine.IndexOf(shaderFeature) + shaderFeature.Length + 1;
                if (startIndex >= 0)
                {
                    string keyword = line.Substring(startIndex);
                    keyword = keyword.Trim();
                    bool toggle = oldKeyWords.Contains(keyword);
                    bool ini = toggle;

                    GUIContent effectNameLabel = new GUIContent();
                    effectNameLabel.tooltip = keyword + " (C#)";
                    effectNameLabel.text = keyword;

                    toggle = EditorGUILayout.BeginToggleGroup(effectNameLabel, toggle);

                    if (ini != toggle) Save();
                    if (toggle)
                    {
                        targetMat.EnableKeyword(keyword);
                    }
                    else
                        targetMat.DisableKeyword(keyword);

                    EditorGUILayout.EndToggleGroup();
                }
            }
        }
    }

    private void Save()
    {
        if (!Application.isPlaying) EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
        EditorUtility.SetDirty(targetMat);
    }
}
