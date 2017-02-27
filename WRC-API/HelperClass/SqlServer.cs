using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace WRC_API.HelperClass
{
    public class SqlServer
    {
        public static string ConnectionString { get; set; }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="command"></param>
        /// <param name="parameters"></param>
        /// <param name="commandType"></param>
        public static void ExecuteDataNQ(string command, Dictionary<string, object> parameters, CommandType commandType)
        {
            Stopwatch innerWatch = new Stopwatch();
            innerWatch.Start();

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                try
                {
                    if (connection.State != ConnectionState.Open)
                        connection.Open();

                    using (SqlCommand sqlCommand = new SqlCommand(command, connection))
                    {
                        sqlCommand.CommandType = commandType;
                        foreach (var param in parameters)
                        {
                            if (param.Value is JObject)
                            {
                                var jObject = (param.Value as JObject);
                                var jTypeValue = Type.GetType(Convert.ToString(((Newtonsoft.Json.Linq.JValue)(jObject["ObjectType"])).Value));
                                var jDataValue = ((Newtonsoft.Json.Linq.JValue)(jObject["ObjectData"])).Value;

                                var paramValue = Encoding.ASCII.GetBytes(Convert.ToString(jDataValue));
                                sqlCommand.Parameters.Add(new SqlParameter(param.Key, paramValue));

                            }
                            else
                                sqlCommand.Parameters.Add(new SqlParameter(param.Key, param.Value));
                        }
                        sqlCommand.ExecuteNonQuery();
                        innerWatch.Stop();
                        AppLogger.LogTimer(innerWatch);
                    }
                }
                catch (Exception ex)
                {
                    innerWatch.Stop();
                    AppLogger.LogError(ex);
                }
                finally
                {
                    if (connection.State != ConnectionState.Closed)
                        connection.Close();
                }
            }

        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="command"></param>
        /// <param name="parameters"></param>
        /// <param name="commandType"></param>
        /// <returns></returns>
        public async static Task<DataSet> ExecuteDataAsync(string command, Dictionary<string, object> parameters, CommandType commandType)
        {
            Stopwatch innerWatch = new Stopwatch();
            DataSet dsData = new DataSet();

            innerWatch.Start();

            using (SqlConnection connection = new SqlConnection(ConnectionString))
            {
                try
                {
                    if (connection.State != ConnectionState.Open)
                        connection.Open();

                    using (SqlCommand sqlCommand = new SqlCommand(command, connection))
                    {
                        sqlCommand.CommandType = commandType;
                        foreach (var param in parameters)
                        {
                            sqlCommand.Parameters.Add(new SqlParameter(param.Key, param.Value));
                        }

                        SqlDataAdapter dataAdaptor = new SqlDataAdapter(sqlCommand);
                        await Task.Run(() =>
                            {
                                dataAdaptor.Fill(dsData);
                            });

                        innerWatch.Stop();
                        AppLogger.LogTimer(innerWatch);
                    }
                }
                catch (Exception ex)
                {
                    innerWatch.Stop();
                    AppLogger.LogError(ex);
                }
                finally
                {
                    if (connection.State != ConnectionState.Closed)
                        connection.Close();
                }
                return dsData;
            }
        }
    }
}