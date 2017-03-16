using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using WRC_API.HelperClass;

namespace WRC_API.Model
{
    public class Specific
    {
        public Specific()
        {
            Data = new List<ContentData>();
        }

        public Specific(DataTable contentData)
        {
            Data = new List<ContentData>();
            Data.AddRange(contentData.AsEnumerable().Select(dataRow => new ContentData()
            {
                Oid = CommonClass.GetRowData<int>(dataRow["Id"]),
                Name = CommonClass.GetRowData<string>(dataRow["Name"]),
                Type = CommonClass.ConvertToContentType(Convert.ToInt32(dataRow["Type"])),
                Orientation = CommonClass.GetRowData<string>(dataRow["Orientation"]),
                Data = CommonClass.GetRowData<string>(dataRow["Data"]),
                Description = CommonClass.GetRowData<string>(dataRow["Description"]),
                Order = CommonClass.GetRowData<int>(dataRow["Order"])
            }));
        }

        [JsonProperty("O")]
        public int Oid { get; set; }

        [JsonProperty("N")]
        public string Name { get; set; }

        [JsonProperty("L")]
        public byte[] Logo { get; set; }

        [JsonProperty("OR")]
        public string Orientation { get; set; }

        [JsonProperty("T")]
        public string Title { get; set; }

        [JsonProperty("IA")]
        public bool IsActive { get; set; }

        [JsonProperty("IAu")]
        public bool Authorized { get; set; }

        [JsonProperty("ID")]
        public bool IsDefault { get; set; }

        [JsonProperty("SD")]
        public List<ContentData> Data { get; set; }
    }

    public class ContentData
    {
        [JsonProperty("CO")]
        public int Oid { get; set; }

        [JsonProperty("N")]
        public string Name { get; set; }

        [JsonProperty("O")]
        public ContentType Type { get; set; }

        [JsonProperty("Ori")]
        public string Orientation { get; set; }

        [JsonProperty("D")]
        public object Data { get; set; }

        [JsonProperty("CD")]
        public string Description { get; set; }

        [JsonProperty("Ord")]
        public int Order { get; set; }
    }

    public enum ContentType
    {
        Static = 0,
        COC = 1,
        Search = 2,
    }
}