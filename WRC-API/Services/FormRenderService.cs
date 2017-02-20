using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using WRC_API.HelperClass;

namespace WRC_API.Services
{
    public class FormRenderService
    {
        private SqlServer _sqlServer;
        public FormRenderService() : this(new SqlServer()) { }

        public FormRenderService(SqlServer server)
        {
            _sqlServer = server;
        }

        public void ExecuteNonQuery(string commmandName, Dictionary<string, string> Parameters)
        {
            Task.Run(() =>
                _sqlServer.ExecuteDataNQ(commmandName, Parameters, CommandType.StoredProcedure));
        }

        public async Task<DataTable> ExecuteDataSet(string commmandName, Dictionary<string, string> Parameters)
        {
            return await _sqlServer.ExecuteData(commmandName, Parameters, CommandType.StoredProcedure);
        }

        //public void UpdateNonQuery(string commmandName, Dictionary<string, string> Parameters)
        //{
        //    Task.Run(()=>
        //        _sqlServer.ExecuteDataNQ(commmandName, Parameters, CommandType.StoredProcedure));               
        //}

        //public void DeleteNonQuery(string commmandName, Dictionary<string, string> Parameters)
        //{
        //    Task.Run(() =>
        //         _sqlServer.ExecuteDataNQ(commmandName, Parameters, CommandType.StoredProcedure));
        //}
    }
}