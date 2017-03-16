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

        public static string MiniFyAndCompressData(string dataToCompress)
        {
            var JsonResult = JsonConvert.SerializeObject(dataToCompress, Formatting.None);
            var minifyJson = Regex.Replace(JsonResult, "(\"(?:[^\"\\\\]|\\\\.)*\")|\\s+", "$1");
            var compStr = GZip.GZipCompressDecompress.Zip(minifyJson);
            return dataToCompress;
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

        public static T GetRowData<T>(object dr)
        {
            if (!object.ReferenceEquals(dr, null) && !(dr is System.DBNull))
            {
                if (typeof(T) == typeof(byte[]))
                    return (T)Convert.ChangeType(System.Text.Encoding.ASCII.GetBytes(Convert.ToString(dr)), typeof(T));
                return (T)Convert.ChangeType(dr, typeof(T));
            }
            return default(T);
        }
    }
}