using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Linq;

namespace UAVPlayerUtility
{
    public static class UAVPUtility
    {
        public static string[] GetStreamingAssetVideoFiles()
        {
            DirectoryInfo directoryInfo = new DirectoryInfo(Application.streamingAssetsPath);
            HashSet<string> files = new HashSet<string>();

            foreach(FileInfo assetFile in directoryInfo.GetFiles("*.*", SearchOption.AllDirectories))
            {
                if(assetFile.Exists)
                {
                    if((assetFile.FullName.EndsWith(".meta") == false) && assetFile.FullName.EndsWith(".mp4"))
                    {
                        string[] fileSplitPart;
                        string result = "";
                        int index = -1;

                        string assetFileFullPath = assetFile.FullName;
                        fileSplitPart = assetFileFullPath.Split('/');

                        for(int i = 0; i < fileSplitPart.Length; i++)
                        {
                            if(Application.platform == RuntimePlatform.IPhonePlayer)
                            {
                                if(i != 0 && fileSplitPart[i - 1].Equals("Data") && fileSplitPart[i].Equals("Raw"))
                                {
                                    index = i + 1;
                                    result = fileSplitPart[index];
                                    index++;
                                }
                            }
                            else
                            {
                                if(fileSplitPart[i].Equals("StreamingAssets"))
                                {
                                    index = i + 1;
                                    result = fileSplitPart[index];
                                    index++;
                                }
                            }

                            if(index < fileSplitPart.Length && index != -1)
                            {
                                result += "/" + fileSplitPart[index];
                                index++;
                            }
                        }
                        files.Add(result);
                    }
                }
            }
            if(files.Count != 0)
            {
                return files.ToArray();
            }
            else
            {
                return null;
            }
        }
    }
}