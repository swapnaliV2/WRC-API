﻿using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using WRC_API.HelperClass;
using WRC_API.Model;

namespace WRC_API.Services
{
    public class FormRenderService
    {
        /// <summary>
        /// 
        /// </summary>
        /// <param name="commmandName"></param>
        /// <param name="parameters"></param>
        public void RaiseDBRequestAndForget(string commmandName, Dictionary<string, object> parameters)
        {
            Task.Run(() =>
               ProcessDBOperation(commmandName, parameters));
        }

        void ProcessDBOperation(string commmandName, Dictionary<string, object> Parameters)
        {
            SqlServer.ExecuteDataNQ(commmandName, Parameters, CommandType.StoredProcedure);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="commmandName"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public async Task<DataSet> ExecuteDataSet(string commmandName, Dictionary<string, object> parameters)
        {
            return await SqlServer.ExecuteDataAsync(commmandName, parameters, CommandType.StoredProcedure);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="commmandName"></param>
        /// <param name="Parameters"></param>
        /// <returns></returns>
        public async Task<object> RenderViewData(int siteId, int viewId, Dictionary<string, object> parameters)
        {
            var isGlobalData = parameters["@Global"];
            var isFrequentData = parameters["@Frequent"];
            var isEncryptData = parameters["@IsEncrypt"];
            string commmandName = "Sp_RenderView";

            Dictionary<string, object> commandParameters = new Dictionary<string, object>();
            commandParameters.Add("@SiteId", siteId);
            commandParameters.Add("@ViewId", viewId);

            using (DataSet dataSet = await SqlServer.ExecuteDataAsync(commmandName, commandParameters, CommandType.StoredProcedure))
            {
                Dictionary<string, object> obje = new Dictionary<string, object>();

                if (Convert.ToString(isGlobalData) == "1")
                {
                    if (dataSet.Tables.Count > 0 && dataSet.Tables[0].Rows.Count > 0)
                    {
                        var dataRow = dataSet.Tables[0].Rows[0];
                        obje.Add("g", new Global(dataSet.Tables[1])
                        {
                            Oid = int.Parse(dataRow["Id"].ToString()),
                            Name = dataRow["Name"].ToString(),
                            URL = dataRow["url"].ToString(),
                            Logo = (byte[])dataRow["Logo"],
                            Title = dataRow["Title"].ToString(),
                            IsActive = Convert.ToBoolean(dataRow["IsActive"])
                        });
                    }
                }

                if (Convert.ToString(isFrequentData) == "1")
                {
                    //if (dataSet.Tables.Count > 1)
                    //    obje.Add("f", dataSet.Tables[1]);
                }

                if (dataSet.Tables.Count > 2)
                    obje.Add("s", dataSet.Tables[2].AsEnumerable().Select(dataRow => new Specific(dataSet.Tables[3])
                    {
                        Oid = int.Parse(dataRow["Id"].ToString()),
                        Orientation = dataRow["Orientation"].ToString()
                    }).ToList());

                try
                {
                    if (Convert.ToString(isEncryptData) == "1")
                    {
                        return CommonClass.MiniFyAndCompressData(obje);
                    }
                }
                catch (JsonSerializationException exception)
                {
                    AppLogger.LogError(exception);
                    throw;
                }


                return obje;
            }
        }
    }
}