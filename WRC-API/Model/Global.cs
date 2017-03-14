using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;

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
                           Oid = int.Parse(dataRow["Id"].ToString()),
                           Name = dataRow["Name"].ToString(),
                           IsExternal = Convert.ToBoolean(dataRow["IsExternal"].ToString()),
                           Order = int.Parse(dataRow["Order"].ToString()),
                           ViewId = int.Parse(dataRow["ViewId"].ToString())
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