using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using WRC_API.Model;

namespace WRC_API.HelperClass
{
    public class CommonClass
    {
        public static void DeCompressData()
        {
            //TODO: Convert compress data into original format
            //Dictionary<string, object> dcomstr;
            //var Result = JsonConvert.SerializeObject (paramSet.ToString());
            //var comStr = GZipCompressDecompress.Zip(Result.ToString ());
            //var decomStr1 = GZipCompressDecompress.UnZip(comStr); 
        }

        public static string MiniFyAndCompressData(object dataToCompress)
        {
            var JsonResult = JsonConvert.SerializeObject(dataToCompress, Formatting.None);
            var minifyJson = Regex.Replace(JsonResult, "(\"(?:[^\"\\\\]|\\\\.)*\")|\\s+", "$1");
            var compStr = GZip.GZipCompressDecompress.Zip(minifyJson);
            return JsonResult;
        }
        public static string CompressData(string dataToCompress)
        {
            var compStr = GZip.GZipCompressDecompress.Zip(dataToCompress);
            return compStr;
        }

        public static string ConvertToJsonString(object data)
        {
            string jsonString = string.Empty;
            try
            {
                jsonString = JsonConvert.SerializeObject(data);
            }
            catch (JsonSerializationException exception)
            {
                Console.Write(exception.Message);
                throw;
            }
            return jsonString;

        }

        public static ContentType ConvertToContentType(int contentType)
        {
            switch (contentType)
            {
                case 0:
                    return ContentType.Static;
                case 1:
                    return ContentType.COC;
                case 2:
                    return ContentType.Search;
            }

            return default(ContentType);
        }
    }
}