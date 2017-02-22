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
        /// <summary>
        /// 
        /// </summary>
        /// <param name="commmandName"></param>
        /// <param name="Parameters"></param>
        public void RaiseDBRequestAndForget(string commmandName, Dictionary<string, object> Parameters)
        {
            Task.Run(() =>
                SqlServer.ExecuteDataNQ(commmandName, Parameters, CommandType.StoredProcedure));
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="commmandName"></param>
        /// <param name="Parameters"></param>
        /// <returns></returns>
        public async Task<DataSet> ExecuteDataSet(string commmandName, Dictionary<string, object> Parameters)
        {
            return await SqlServer.ExecuteDataAsync(commmandName, Parameters, CommandType.StoredProcedure);
        }
    }
}