using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using WRC_API.HelperClass;

namespace WRC_API.Model
{
    //[JsonObject("G")]
    public class Global
    {
        public Global()
        {
            Menu = new List<Menu>();
        }

        public Global(DataTable menuData)
        {
            Menu = new List<Menu>();
            Menu.AddRange(menuData.AsEnumerable().Select(dataRow => new Menu()
                       {
                           Oid = CommonClass.GetRowData<int>(dataRow["Id"]),
                           Name = CommonClass.GetRowData<string>(dataRow["Name"]),
                           IsExternal = CommonClass.GetRowData<bool>(dataRow["IsExternal"]),
                           Order = CommonClass.GetRowData<int>(dataRow["Order"]),
                           ViewId = CommonClass.GetRowData<int>(dataRow["ViewId"])
                       }));
        }

        [JsonProperty("O")]
        public int Oid { get; set; }

        [JsonProperty("N")]
        public string Name { get; set; }

        [JsonProperty("U")]
        public string URL { get; set; }

        [JsonProperty("L")]
        public byte[] Logo { get; set; }

        [JsonProperty("T")]
        public string Title { get; set; }

        [JsonProperty("IA")]
        public bool IsActive { get; set; }

        [JsonProperty("M")]
        public List<Menu> Menu { get; set; }

    }

    public class Menu
    {
        [JsonProperty("MN")]
        public int Oid { get; set; }

        [JsonProperty("MV")]
        public string Name { get; set; }

        [JsonProperty("IE")]
        public bool IsExternal { get; set; }

        [JsonProperty("OR")]
        public int Order { get; set; }

        [JsonProperty("VI")]
        public int ViewId { get; set; }
    }
}